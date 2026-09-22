-- Native multicursor (nvim 0.13+), with the ergonomics multicursor-nvim had.
--
-- Builtin commands do most of the work; see `:h mcursor`:
--   Q / {Visual}Q / <C-LeftMouse>  toggle cursors      q=  follow-mode
--   gQ  restore    ]C / [C  jump   CTRL-L  clear       g CTRL-A  counter
--
-- This file adds what the builtin lacks: incremental match selection
-- (VSCode's Ctrl-D), per-line stepping, diagnostic cursors and alignment.

local ok, mc = pcall(require, "vim._core.mcursor")
if not ok then
  vim.notify("native-multicursor: vim._core.mcursor unavailable (needs nvim 0.13+)", vim.log.levels.WARN)
  return
end

-- Cursors are extmarks in this namespace; deleting a mark deletes the cursor.
local ns = vim.api.nvim_create_namespace("nvim.multicursor")

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = "Multicursor: " .. desc })
end

--- Extra cursors, as { row = 1-indexed, col = 0-indexed byte }, in buffer order.
local function cursors()
  local out = {}
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})) do
    out[#out + 1] = { row = m[2] + 1, col = m[3], id = m[1] }
  end
  return out
end

--- Byte column on `lnum` nearest to virtual column `vcol`, clamped to EOL.
--- Mirrors the builtin's handling of tabs/multibyte in `vim._core.mcursor`.
local function bytecol(lnum, vcol)
  if vim.fn.virtcol({ lnum, "$" }) <= vcol then
    return math.max(vim.fn.col({ lnum, "$" }) - 1, 0)
  end
  return math.max(vim.fn.virtcol2col(0, lnum, vcol) - 1, 0)
end

-- ── Pattern seeding ─────────────────────────────────────────────────────────

--- Escape `text` into a "very nomagic" (\V) literal pattern.
local function literal(text)
  return [[\V]] .. text:gsub("\\", "\\\\")
end

--- Search pattern for match-based cursors: the Visual selection if we are in
--- Visual mode (leaving it), else the word under the cursor. Sets @/ so that
--- `n`, `N` and the builtin `[count]Q` all agree with us.
local function seed_pattern()
  local mode = vim.fn.mode()
  local pat
  if mode == "v" or mode == "V" or mode == "\22" then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    vim.cmd.normal({ vim.keycode("<Esc>"), bang = true })
    -- Multi-line selections do not make a useful pattern; fall back to cword.
    if #lines == 1 and lines[1] ~= "" then
      pat = literal(lines[1])
    end
  end
  if not pat then
    local word = vim.fn.expand("<cword>")
    if word == "" then
      return nil
    end
    pat = [[\<]] .. vim.fn.escape(word, [[\/]]) .. [[\>]]
  end
  vim.fn.setreg("/", pat)
  if vim.o.hlsearch then
    vim.v.hlsearch = 1
  end
  return pat
end

--- Pattern for the current session: reuse @/ once cursors exist, so repeated
--- presses keep matching the original word rather than whatever we landed on.
local function session_pattern()
  if mc.active() then
    local reg = vim.fn.getreg("/")
    if reg ~= "" then
      return reg
    end
  end
  return seed_pattern()
end

-- ── Match cursors (the Ctrl-D flow) ─────────────────────────────────────────

--- Add or skip a cursor at the next/previous match of the cursor word.
--- @param dir integer 1 forward, -1 backward
--- @param skip boolean true to move the primary cursor without leaving one behind
local function match_cursor(dir, skip)
  local fresh = not mc.active()
  local pat = session_pattern()
  if not pat then
    return
  end
  -- On the first press the cursor may sit mid-word: normalise to the match
  -- start so the cursor we leave behind lines up with every later one.
  if fresh then
    vim.fn.search(pat, "bcW")
  end
  if not skip then
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_mcursor(0, { pos[1], pos[2] })
  end
  if vim.fn.search(pat, dir > 0 and "w" or "bw") == 0 then
    vim.notify("No more matches", vim.log.levels.INFO)
  end
end

--- Place a cursor at every match of the cursor word / Visual selection.
local function match_all()
  if not seed_pattern() then
    return
  end
  mc.matches()
end

map({ "n", "x" }, "<M-n>", function()
  match_cursor(1, false)
end, "add cursor at next match")
map({ "n", "x" }, "<M-N>", function()
  match_cursor(-1, false)
end, "add cursor at previous match")
map({ "n", "x" }, "<M-s>", function()
  match_cursor(1, true)
end, "skip to next match")
map({ "n", "x" }, "<M-S>", function()
  match_cursor(-1, true)
end, "skip to previous match")
map({ "n", "x" }, "<M-a>", match_all, "add cursor at all matches")

-- ── Line cursors ────────────────────────────────────────────────────────────

--- Step the primary cursor one line, optionally leaving a cursor behind.
--- Column is preserved virtually, so tabs and multibyte text line up.
local function line_cursor(dir, skip)
  local pos = vim.api.nvim_win_get_cursor(0)
  local target = pos[1] + dir
  if target < 1 or target > vim.api.nvim_buf_line_count(0) then
    return
  end
  local vcol = vim.fn.virtcol(".")
  if not skip then
    vim.api.nvim_mcursor(0, { pos[1], pos[2] })
  end
  vim.api.nvim_win_set_cursor(0, { target, bytecol(target, vcol) })
end

map({ "n", "x" }, "<M-j>", function()
  line_cursor(1, false)
end, "add cursor on line below")
map({ "n", "x" }, "<M-k>", function()
  line_cursor(-1, false)
end, "add cursor on line above")
map({ "n", "x" }, "<M-down>", function()
  line_cursor(1, true)
end, "skip cursor to line below")
map({ "n", "x" }, "<M-up>", function()
  line_cursor(-1, true)
end, "skip cursor to line above")

-- ── Diagnostic cursors ──────────────────────────────────────────────────────

--- Jump to the next/previous diagnostic, optionally leaving a cursor behind.
local function diagnostic_cursor(dir, skip)
  if not skip then
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_mcursor(0, { pos[1], pos[2] })
  end
  vim.diagnostic.jump({ count = dir, float = false })
end

--- Place a cursor at every error diagnostic in the buffer.
local function diagnostic_all(severity)
  local diags = vim.diagnostic.get(0, { severity = severity })
  if #diags == 0 then
    vim.notify("No diagnostics", vim.log.levels.INFO)
    return
  end
  for _, d in ipairs(diags) do
    vim.api.nvim_mcursor(0, { d.lnum + 1, d.col })
  end
end

-- NOTE: `<M-]d>` in the old config never parsed -- `<M-x>` takes exactly one
-- character -- so these are on single-character keys now.
map({ "n", "x" }, "<M-]>", function()
  diagnostic_cursor(1, false)
end, "add cursor at next diagnostic")
map({ "n", "x" }, "<M-[>", function()
  diagnostic_cursor(-1, false)
end, "add cursor at previous diagnostic")
map({ "n", "x" }, "<M-}>", function()
  diagnostic_cursor(1, true)
end, "skip to next diagnostic")
map({ "n", "x" }, "<M-{>", function()
  diagnostic_cursor(-1, true)
end, "skip to previous diagnostic")
map({ "n", "x" }, "<M-d>", function()
  diagnostic_all(vim.diagnostic.severity.ERROR)
end, "add cursors at all errors")

-- ── Align ───────────────────────────────────────────────────────────────────

--- Pad with spaces so cursors share a virtual column: the 1st cursor of every
--- line aligns with the other 1st cursors, the 2nd with the 2nd, and so on.
--- Extmarks shift themselves as we insert, so positions are re-read each round.
local function align()
  if not mc.active() then
    return
  end
  for nth = 1, 64 do
    local by_row = {}
    for _, c in ipairs(cursors()) do
      by_row[c.row] = by_row[c.row] or {}
      table.insert(by_row[c.row], c.col)
    end
    -- The nth cursor of each line, and the column they must all reach.
    local kth, target = {}, 0
    for row, cols in pairs(by_row) do
      table.sort(cols)
      if cols[nth] then
        kth[row] = cols[nth]
        target = math.max(target, vim.fn.virtcol({ row, cols[nth] + 1 }))
      end
    end
    if not next(kth) then
      return
    end
    for row, col in pairs(kth) do
      local pad = target - vim.fn.virtcol({ row, col + 1 })
      if pad > 0 then
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { string.rep(" ", pad) })
      end
    end
  end
end

map("n", "<M-A>", align, "align cursor columns")

-- ── Session management ──────────────────────────────────────────────────────

--- Delete the extra cursor nearest the primary cursor.
local function delete_nearest()
  local list = cursors()
  if #list == 0 then
    return
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  local best, best_dist
  for _, c in ipairs(list) do
    local dist = math.abs(c.row - pos[1]) * 10000 + math.abs(c.col - pos[2])
    if not best_dist or dist < best_dist then
      best, best_dist = c, dist
    end
  end
  vim.api.nvim_buf_del_extmark(0, ns, best.id)
end

map("n", "<leader>x", delete_nearest, "delete nearest cursor")
map("n", "<M-u>", mc.restore, "restore cleared cursors")

-- Counters. `g CTRL-A` is the builtin; these add a decrementing variant and
-- honour a [count] as the starting number.
map("n", "<M-c>", function()
  mc.number(vim.v.count1, 1)
end, "number cursors ascending")
map("n", "<M-C>", function()
  mc.number(vim.v.count1, -1)
end, "number cursors descending")

--- Run `builtin` only while cursors exist, else fall through to the default key.
local function when_active(builtin, fallback)
  return function()
    if mc.active() then
      builtin()
    else
      vim.api.nvim_feedkeys(vim.keycode(fallback), "n", false)
    end
  end
end

map("n", "<left>", when_active(function()
  mc.jump(false, vim.v.count1)
end, "<left>"), "previous cursor")
map("n", "<right>", when_active(function()
  mc.jump(true, vim.v.count1)
end, "<right>"), "next cursor")

-- `<esc>` can't go through `when_active`: its fallback replays a noremap'd
-- `<esc>`, which skips mappings on purpose (else it would recurse into this
-- one) and so never reaches the `:noh` map from core/options.lua. Do the
-- highlight clearing here instead, so `<esc>` keeps both jobs.
map("n", "<esc>", function()
  if mc.active() then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  else
    vim.cmd("nohlsearch")
  end
end, "clear cursors / search highlight")
