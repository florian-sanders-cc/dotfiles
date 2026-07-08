-- ┌──────────────────────────────────────┐
-- │ CodeDiff: Persistent Annotations      │
-- └──────────────────────────────────────┘
--
-- Inline review annotations for CodeDiff (vscode-diff.nvim) diff buffers
-- and regular file buffers, persisted per cwd to a JSON file and rendered
-- via `nvim_buf_set_extmark` virtual lines.
--
-- Storage layout (`<cwd>/.nvim/codediff-annotations.json`):
--   { ["work:<cwd-rel-path>"]   = { [1] = { text, line, end_line }, ... },
--     ["rev:<commit>:<root-rel>"] = { ... } }
--
-- `work:` keys annotate real working-tree files (regular buffers + diff
-- buffers whose revision is nil or "WORKING"). `rev:` keys annotate git
-- revision virtual buffers (`codediff://…`), keyed by `<commit>:<path>` as
-- parsed from the virtual-file URL.
--
-- User autocmds consumed: `CodeDiffOpen`, `CodeDiffVirtualFileLoaded`,
-- `CodeDiffFileSelect`.

local M = {}

local api = vim.api
local fn = vim.fn
local uv = vim.uv or vim.loop

local NS
local BVAR = "codediff_ann_marks" -- bufvar: map key -> { start = id, endp = id|nil }

-- ───────────────────────────────────────
-- config
-- ───────────────────────────────────────

local CFG = {
  ns_name = "git.codediff-annotate",
  hl_mark = "CodeDiffAnnotateMark",
  hl_text = "CodeDiffAnnotateText",
  hl_box = "CodeDiffAnnotateBox",
  hl_mark_resolved = "CodeDiffAnnotateMarkResolved",
  hl_text_resolved = "CodeDiffAnnotateTextResolved",
  hl_box_resolved = "CodeDiffAnnotateBoxResolved",
  file = ".nvim/codediff-annotations.json",
  max_width = 72,
  prompt = "Review annotation",
  priority = 2048, -- above diagnostics & diff signs
}

-- Highlight groups. Defined once at setup; can be overridden by theme.
local function setup_highlights()
  local defs = {
    [CFG.hl_mark] = { default = true, link = "DiagnosticInfo" },
    [CFG.hl_box] = { default = true, link = "Comment" },
    [CFG.hl_text] = { default = true, link = "NormalFloat" },
    [CFG.hl_mark_resolved] = { default = true, link = "Comment" },
    [CFG.hl_box_resolved] = { default = true, link = "Comment" },
    [CFG.hl_text_resolved] = { default = true, italic = true, link = "Comment" },
  }
  for name, spec in pairs(defs) do
    api.nvim_set_hl(0, name, spec)
  end
end

-- ───────────────────────────────────────
-- path / key resolution
-- ───────────────────────────────────────

-- Absolute path of a regular (non-virtual) buffer, or nil.
local function buf_realpath(buf)
  local buftype = vim.bo[buf].buftype
  if buftype ~= "" then
    return nil
  end
  local name = api.nvim_buf_get_name(buf)
  if name == "" or name:match("^codediff://") then
    return nil
  end
  return fn.fnamemodify(name, ":p")
end

-- Path relative to cwd, nil if not under cwd.
local function cwd_rel(abs)
  if not abs then
    return nil
  end
  local cwd = fn.getcwd()
  local rel = fn.fnamemodify(abs, ":.")
  -- If not under cwd, fnamemodify returns the full path.
  if abs == rel or rel == abs or not (abs:sub(1, #cwd) == cwd) then
    return nil
  end
  return rel
end

-- Classify a buffer into a storage key, or nil if unannotatable here.
-- Returns: key, is_virtual, commit, relpath
local function classify_buf(buf)
  local name = api.nvim_buf_get_name(buf)
  if name:match("^codediff://") then
    local ok, vf = pcall(require, "codediff.core.virtual_file")
    if not ok then
      return nil
    end
    local root, commit, path = vf.parse_url(name)
    if root and commit and path then
      return "rev:" .. commit .. ":" .. path, true, commit, path
    end
    return nil
  end
  local abs = buf_realpath(buf)
  if not abs then
    return nil
  end
  local rel = cwd_rel(abs)
  if not rel then
    return nil
  end
  return "work:" .. rel, false, nil, rel
end

-- Current annotation context for a buffer: key + cursor line range.
local function ctx(buf)
  local key, is_virtual = classify_buf(buf)
  if not key then
    return nil
  end
  return key, is_virtual
end

-- Decode the two key forms back to a display label and, for rev: keys, the
-- owner file's working-tree path (so `rl` can offer regular buffers too).
local function key_label(key)
  local kind, rest = key:match("^(%w+):(.+)$")
  if kind == "rev" then
    local commit, path = rest:match("^([^:]+):(.+)$")
    if commit then
      return ("rev %s @ %s"):format(commit:sub(1, 8), vim.fn.fnamemodify(path, ":t")), path
    end
  elseif kind == "work" then
    return vim.fn.fnamemodify(rest, ":t"), rest
  end
  return key, nil
end

-- ───────────────────────────────────────
-- storage
-- ───────────────────────────────────────

local store_path = function()
  return fn.getcwd() .. "/" .. CFG.file
end

local function read_store()
  local p = store_path()
  local fd = io.open(p, "r")
  if not fd then
    return {}
  end
  local body = fd:read("*a")
  fd:close()
  if body == nil or body == "" then
    return {}
  end
  local ok, data = pcall(vim.json and vim.json.decode or fn.json_decode, body)
  return ok and data or {}
end

local function write_store(data)
  -- Prune empty keys.
  local clean = {}
  for k, v in pairs(data) do
    if type(v) == "table" and next(v) ~= nil then
      clean[k] = v
    end
  end
  local dir = fn.fnamemodify(store_path(), ":h")
  fn.mkdir(dir, "p")
  local fd = io.open(store_path(), "w")
  if not fd then
    vim.notify("[codediff-annotate] cannot write " .. store_path(), vim.log.levels.ERROR)
    return
  end
  local json = vim.json and vim.json.encode(clean) or fn.json_encode(clean)
  fd:write(json)
  fd:close()
end

-- Annotations for a key (1-indexed list of {text,line,end_line}).
-- Lines are clamped to >= 1 on read: buffer rows are 1-indexed, so a stored
-- 0 (or negative) can only come from a bad writer and would otherwise render
-- silently at the top of the file.
local function get_anns(key)
  local data = read_store()
  local anns = data[key] or {}
  for _, ann in ipairs(anns) do
    ann.line = math.max(1, tonumber(ann.line) or 1)
    if ann.end_line then
      ann.end_line = math.max(ann.line, tonumber(ann.end_line) or ann.line)
    end
  end
  return anns
end

local function save_anns(key, anns)
  local data = read_store()
  data[key] = anns
  write_store(data)
end

local function delete_key(key)
  local data = read_store()
  data[key] = nil
  write_store(data)
end

-- ───────────────────────────────────────
-- rendering
-- ───────────────────────────────────────

-- Build a virt_lines spec (list of lines, each a list of {text, hl} chunks).
local function build_virt_lines(ann)
  local text = ann.text or ""
  local opts_iter = vim.split(text, "\n", { plain = true })
  local resolved = ann.resolved == true

  local hl_box = resolved and CFG.hl_box_resolved or CFG.hl_box
  local hl_text = resolved and CFG.hl_text_resolved or CFG.hl_text
  local dash = resolved and "┄" or "─"
  local body_prefix = resolved and "┊  " or "│  "
  local check = resolved and "✓ " or ""

  -- Single-line range: a compact box above.
  if not ann.end_line or ann.end_line <= ann.line then
    local line = {}
    table.insert(line, { "╭" .. dash .. " " .. check, hl_box })
    if text ~= "" then
      table.insert(line, { text, hl_text })
    end
    table.insert(line, { " " .. dash .. dash .. "╮", hl_box })
    return { line }
  end

  -- Multi-line range: open bracket above start line, close bracket above
  -- end line. Text wraps below.
  local top = {}
  table.insert(top, { "╭" .. dash .. " " .. check, hl_box })
  if #opts_iter > 0 and opts_iter[1] ~= "" then
    table.insert(top, { " " .. opts_iter[1], hl_text })
  end
  table.insert(top, { " " .. dash .. dash, hl_box })
  local lines = { top }
  for i = 2, #opts_iter do
    table.insert(lines, { { body_prefix, hl_box }, { opts_iter[i], hl_text } })
  end
  return lines, true
end

local function end_virt_lines(ann)
  local span = (ann.end_line or ann.line) - ann.line + 1
  local resolved = ann.resolved == true
  local dash = resolved and "┄" or "─"
  local hl_box = resolved and CFG.hl_box_resolved or CFG.hl_box
  local dashes = string.rep(dash, math.max(3, span + 4))
  return { { { "╰", hl_box }, { dashes, hl_box }, { "╯", hl_box } } }
end

-- Clear a single extmark id iff still valid; returns true if removed.
local function clear_mark(buf, id)
  if not id then
    return false
  end
  if api.nvim_buf_is_valid(buf) then
    pcall(api.nvim_buf_del_extmark, buf, NS, id)
  end
  return true
end

-- Replace any prior annotations for `key` on `buf` with current store state.
-- Renders one extmark per annotation; tracks ids in buf var BVAR[key].
local function render_for_key(buf, key)
  if not api.nvim_buf_is_valid(buf) then
    return
  end

  local marks = vim.b[buf][BVAR] or {}
  -- Clear previous marks for this key only.
  if marks[key] then
    for _, m in ipairs(marks[key].annotations or {}) do
      clear_mark(buf, m.start)
      clear_mark(buf, m.endp)
    end
    marks[key] = nil
  end

  local anns = get_anns(key)
  if #anns == 0 then
    vim.b[buf][BVAR] = marks
    return
  end

  local ok_all = true
  for _, ann in ipairs(anns) do
    local nlines = api.nvim_buf_line_count(buf)
    local sr = math.max(0, math.min((ann.line or 1) - 1, nlines - 1))
    local vlines, is_multi = build_virt_lines(ann)
    local start_id, end_id
    local ok, s_id = pcall(api.nvim_buf_set_extmark, buf, NS, sr, 0, {
      virt_lines = vlines,
      virt_lines_above = true,
      hl_mode = "combine",
      right_gravity = false,
      priority = CFG.priority,
    })
    if not ok then
      ok_all = false
    else
      start_id = s_id
      if is_multi and ann.end_line then
        local er = math.max(0, math.min(ann.end_line - 1, nlines - 1))
        local e_ok, e_id = pcall(api.nvim_buf_set_extmark, buf, NS, er, 0, {
          virt_lines = end_virt_lines(ann),
          virt_lines_above = true,
          hl_mode = "combine",
          right_gravity = true,
          priority = CFG.priority,
        })
        if e_ok then
          end_id = e_id
        end
      end
    end
    marks[key] = marks[key] or { annotations = {} }
    table.insert(marks[key].annotations, { start = start_id, endp = end_id })
  end

  -- For multi-annotation simplicity we only keep the per-key marks list.
  -- The latest render replaces prior ids; collect as plain list.
  if not ok_all then
    -- partial — still write what we have
  end
  vim.b[buf][BVAR] = marks
end

-- Find annotation index in `anns` whose extmark start row is `row` (0-indexed).
-- Also returns the extmark id (from buf var) if found, else nil.
local function ann_at_row(buf, key, row)
  local anns = get_anns(key)
  local marks = vim.b[buf][BVAR] or {}
  local km = marks[key]
  if not km then
    return nil, nil, nil
  end
  local list = km.annotations or {}
  for i, ann in ipairs(anns) do
    local sr = (ann.line or 1) - 1
    local er = (ann.end_line or ann.line) - 1
    if row >= sr and row <= er then
      local m = list[i]
      return i, ann, m
    end
  end
  return nil
end

-- ───────────────────────────────────────
-- keymaps
-- ───────────────────────────────────────

local function bufopts(desc)
  return { buffer = 0, noremap = true, silent = true, nowait = true, desc = desc }
end

local function set_keymaps(buf)
  if not api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.b[buf].codediff_ann_maps then
    return
  end
  vim.b[buf].codediff_ann_maps = true

  local function add(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, bufopts(desc))
  end

  add("n", "<leader>ra", M.add, "Review: add annotation")
  add("v", "<leader>ra", M.add_range, "Review: annotate range")
  add("n", "<leader>rd", M.delete_under_cursor, "Review: delete annotation")
  add("n", "<leader>rA", M.delete_all_buf, "Review: delete all (buffer)")
  add("n", "<leader>rl", M.list, "Review: list / jump")
end

-- ───────────────────────────────────────
-- public actions
-- ───────────────────────────────────────

local function prompt_text(cb)
  vim.ui.input({ prompt = CFG.prompt .. ": " }, function(t)
    cb(t)
  end)
end

-- Add a single-line annotation at the cursor line of current buffer.
function M.add()
  local buf = api.nvim_get_current_buf()
  local key = ctx(buf)
  if not key then
    vim.notify("[codediff-annotate] not an annotatable buffer", vim.log.levels.WARN)
    return
  end
  local row = api.nvim_win_get_cursor(0)[1] -- 1-indexed
  prompt_text(function(text)
    if not text or text == "" then
      return
    end
    local anns = get_anns(key)
    table.insert(anns, { text = text, line = row })
    table.sort(anns, function(a, b)
      return (a.line or 0) < (b.line or 0)
    end)
    save_anns(key, anns)
    render_for_key(buf, key)
    -- Also mirror to any peer buffer with the same key (e.g. diff modified
    -- side + regular buffer) that is currently loaded.
    M.refresh_peers(buf, key)
  end)
end

-- Resolve the line range of the selection this mapping was invoked from.
-- The `v` mapping fires while visual mode is still active, so `'<`/`'>` are
-- not yet written (they hold the *previous* selection, or 0 if there was
-- none). Use the live anchor/cursor pair instead, and only fall back to the
-- marks when called from normal mode.
local function selection_range()
  local mode = api.nvim_get_mode().mode
  if mode:match("^[vV\22]") then
    local srow, erow = fn.line("v"), fn.line(".")
    if srow > erow then
      srow, erow = erow, srow
    end
    -- Leave visual mode so vim.ui.input gets a clean state.
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    return srow, erow
  end
  local srow = api.nvim_buf_get_mark(0, "<")[1]
  local erow = api.nvim_buf_get_mark(0, ">")[1]
  if srow < 1 or erow < 1 or erow < srow then
    return nil
  end
  return srow, erow
end

-- Visual-range annotation (visual mode mapping).
function M.add_range()
  local buf = api.nvim_get_current_buf()
  local key = ctx(buf)
  if not key then
    vim.notify("[codediff-annotate] not an annotatable buffer", vim.log.levels.WARN)
    return
  end
  local srow, erow = selection_range()
  if not srow then
    vim.notify("[codediff-annotate] bad range", vim.log.levels.WARN)
    return
  end
  prompt_text(function(text)
    if not text or text == "" then
      return
    end
    local anns = get_anns(key)
    table.insert(anns, { text = text, line = srow, end_line = erow })
    table.sort(anns, function(a, b)
      return (a.line or 0) < (b.line or 0)
    end)
    save_anns(key, anns)
    render_for_key(buf, key)
    M.refresh_peers(buf, key)
  end)
end

-- Delete the annotation under the cursor (matches start..end range).
function M.delete_under_cursor()
  local buf = api.nvim_get_current_buf()
  local key = ctx(buf)
  if not key then
    return
  end
  local row = api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
  local idx = ann_at_row(buf, key, row)
  if not idx then
    vim.notify("[codediff-annotate] no annotation under cursor", vim.log.levels.INFO)
    return
  end
  local anns = get_anns(key)
  table.remove(anns, idx)
  save_anns(key, anns)
  render_for_key(buf, key)
  M.refresh_peers(buf, key)
end

-- Delete all annotations for the current buffer's key (with confirm).
function M.delete_all_buf()
  local buf = api.nvim_get_current_buf()
  local key = ctx(buf)
  if not key then
    return
  end
  local anns = get_anns(key)
  if #anns == 0 then
    vim.notify("[codediff-annotate] nothing to delete", vim.log.levels.INFO)
    return
  end
  vim.ui.select({ "Yes", "No" }, {
    prompt = ("Delete %d annotation(s) for this buffer?"):format(#anns),
  }, function(choice)
    if choice ~= "Yes" then
      return
    end
    delete_key(key)
    render_for_key(buf, key)
    M.refresh_peers(buf, key)
  end)
end

-- List annotations for current buffer in a float; jump on selection.
function M.list()
  local win = api.nvim_get_current_win()
  local buf = api.nvim_get_current_buf()
  local key = ctx(buf)
  if not key then
    return
  end
  local anns = get_anns(key)
  if #anns == 0 then
    vim.notify("[codediff-annotate] no annotations", vim.log.levels.INFO)
    return
  end

  local label = key_label(key)
  local items = {}
  for _, ann in ipairs(anns) do
    local span = ann.end_line and (ann.end_line - ann.line + 1) or 1
    local head = ann.text or ""
    if #head > 48 then
      head = head:sub(1, 45) .. "…"
    end
    local mark = ann.resolved == true and "✓ " or ""
    table.insert(items, {
      line = ann.line,
      text = ("%sL%d (%dx) %s"):format(mark, ann.line, span, head),
    })
  end

  -- snacks picker (preferred) → float fallback.
  local ok, picker = pcall(require, "snacks.picker")
  if ok and picker then
    picker.select(items, {
      prompt = "Annotations: " .. label,
      format_item = function(item)
        return item.text
      end,
    }, function(sel, idx)
      local target = (idx and items[idx]) or sel
      if not target or not api.nvim_win_is_valid(win) then
        return
      end
      local last = api.nvim_buf_line_count(api.nvim_win_get_buf(win))
      local row = math.max(1, math.min(target.line, last))
      api.nvim_set_current_win(win)
      api.nvim_win_set_cursor(win, { row, 0 })
      vim.cmd("normal! zv")
    end)
    return
  end

  -- Plain float fallback. Build buffer + keymaps for O / <C-CR> to jump.
  local width = math.min(78, math.max(40, #label + 20))
  local float = api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = #items + 1,
    row = math.floor((vim.o.lines - #items - 1) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. label .. " ",
    title_pos = "center",
  })
  local fbuf = api.nvim_win_get_buf(float)
  vim.bo[fbuf].buftype = "nofile"
  vim.bo[fbuf].bufhidden = "wipe"
  local lines = {}
  for _, it in ipairs(items) do
    table.insert(lines, it.text)
  end
  api.nvim_buf_set_lines(fbuf, 0, -1, false, lines)

  local function jump_close()
    local idx = api.nvim_win_get_cursor(float)[1]
    api.nvim_win_close(float, true)
    local target = items[idx]
    if target then
      api.nvim_win_set_cursor(0, { target.line, 0 })
    end
  end
  vim.keymap.set("n", "O", jump_close, { buffer = fbuf, nowait = true, silent = true })
  vim.keymap.set("n", "<C-CR>", jump_close, { buffer = fbuf, nowait = true, silent = true })
  vim.keymap.set("n", "<CR>", jump_close, { buffer = fbuf, nowait = true, silent = true })
  vim.keymap.set("n", "q", function()
    api.nvim_win_close(float, true)
  end, { buffer = fbuf, nowait = true, silent = true })
end

-- ───────────────────────────────────────
-- application / refresh entry points
-- ───────────────────────────────────────

-- Apply (render + keymaps) to a single buffer if it carries annotations.
function M.apply(buf)
  buf = buf or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(buf) then
    return
  end
  local key = ctx(buf)
  if not key then
    return
  end
  set_keymaps(buf)
  render_for_key(buf, key)
end

-- Re-render on all live buffers whose key matches (peer buffers for the
-- same file across regular views / diff tabs).
function M.refresh_peers(src_buf, key)
  if not api.nvim_buf_is_valid(src_buf) then
    return
  end
  for _, b in ipairs(api.nvim_list_bufs()) do
    if b ~= src_buf and api.nvim_buf_is_loaded(b) then
      local k2 = ctx(b)
      if k2 == key then
        render_for_key(b, key)
      end
    end
  end
end

-- ───────────────────────────────────────
-- diff integration
-- ───────────────────────────────────────

-- Resolve the two diff buffers from a session and apply both. Called on
-- CodeDiffOpen and CodeDiffFileSelect.
local function apply_diff_session(tabpage)
  local ok, lc = pcall(require, "codediff.ui.lifecycle")
  if not ok or not lc or not lc.get_buffers then
    return
  end
  local ob, mb = lc.get_buffers(tabpage)
  if ob then
    M.apply(ob)
  end
  if mb then
    M.apply(mb)
  end
end

-- ───────────────────────────────────────
-- autocmds
-- ───────────────────────────────────────

local group

local function setup_autocmds()
  group = api.nvim_create_augroup("codediff_annotate", { clear = true })

  -- Regular buffer loaded (real file under cwd).
  api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    group = group,
    callback = function(args)
      local buf = args.buf
      local buftype = vim.bo[buf].buftype
      if buftype ~= "" then
        return
      end
      if api.nvim_buf_get_name(buf):match("^codediff://") then
        return
      end
      local key = ctx(buf)
      if not key then
        return
      end
      set_keymaps(buf)
      render_for_key(buf, key)
    end,
  })

  -- Diff open: apply to both diff buffers.
  api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeDiffOpen",
    callback = function(args)
      local tp = args.data and args.data.tabpage
      if not tp then
        return
      end
      vim.schedule(function()
        apply_diff_session(tp)
      end)
    end,
  })

  -- Virtual buffer loaded/refreshed.
  api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeDiffVirtualFileLoaded",
    callback = function(args)
      local buf = args.data and args.data.buf
      if not buf then
        return
      end
      vim.schedule(function()
        M.apply(buf)
      end)
    end,
  })

  -- New file selected in explorer.
  api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeDiffFileSelect",
    callback = function(args)
      local tp = args.data and args.data.tabpage
      if not tp then
        return
      end
      vim.schedule(function()
        apply_diff_session(tp)
      end)
    end,
  })

  -- Sweep after saving a working-tree buffer: prune annotations whose
  -- extmark has vanished (anchored line was deleted).
  api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
      local buf = args.buf
      local key = ctx(buf)
      if not key then
        return
      end
      local marks = vim.b[buf][BVAR] or {}
      local km = marks[key]
      if not km or not km.annotations then
        return
      end
      local anns = get_anns(key)
      if #anns == 0 then
        return
      end
      local keep = {}
      for i, ann in ipairs(anns) do
        local m = km.annotations[i]
        local valid = false
        if m and m.start then
          local found = api.nvim_buf_get_extmark_by_id(buf, NS, m.start, {})
          valid = found ~= nil and #found > 0
        end
        if valid then
          table.insert(keep, ann)
        end
      end
      if #keep ~= #anns then
        save_anns(key, keep)
        render_for_key(buf, key)
        M.refresh_peers(buf, key)
      end
    end,
  })

  -- Drop marks from buf var when a buffer deletes.
  api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      local buf = args.buf
      -- For virtual buffers the buffered content is gone; if it was the
      -- only holder of a `rev:` key, no further cleanup needed (storage
      -- persists and will re-render on next open).
      vim.b[buf][BVAR] = nil
    end,
  })
end

-- ───────────────────────────────────────
-- setup
-- ───────────────────────────────────────

function M.setup(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    CFG[k] = v
  end
  NS = api.nvim_create_namespace(CFG.ns_name)
  setup_highlights()
  setup_autocmds()

  -- Apply to already-loaded buffers (e.g. on config reload).
  vim.schedule(function()
    for _, b in ipairs(api.nvim_list_bufs()) do
      if api.nvim_buf_is_loaded(b) then
        M.apply(b)
      end
    end
  end)
end

return M