-- =====================================================
-- PI INTEGRATION
-- =====================================================
--
-- Keymaps (registered in init.lua):
--   <Leader>ae (visual)  -- edit selection with pi
--   <Leader>as (n/v)     -- send to persistent pi session (async)
--   <Leader>ao (normal)  -- open pi session in terminal split
--
-- Session file: .pi/sessions/neovim.jsonl (project-local)

local M = {}

-- ┌─────────────────────────┐
-- │ Utilities               │
-- └─────────────────────────┘

-- Get the session file path, creating the directory if needed.
local function session_path()
  local cwd = vim.fn.getcwd()
  local dir = cwd .. "/.pi/sessions"
  vim.fn.mkdir(dir, "p")
  return dir .. "/neovim.jsonl"
end

-- Capture visual selection (call immediately when entering the keymap function,
-- before vim.ui.input or any mode change can invalidate the '< and '> marks).
--
-- Returns nil if no selection marks are set.
-- Returns { text, start_line, end_line, start_col, end_col, replace_full_lines }
local function get_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  if start_line == 0 or end_line == 0 then
    return nil
  end

  local lines = vim.fn.getline(start_line, end_line)
  local mode = vim.fn.visualmode(1) -- 1 = return last visual mode even after exit

  -- Line-wise selection (V): replace full lines
  if mode == "V" then
    return {
      text = table.concat(lines, "\n"),
      start_line = start_line,
      end_line = end_line,
      replace_full_lines = true,
    }
  end

  -- Character / block-wise selection: respect columns
  local start_col = vim.fn.col("'<")
  local end_col = vim.fn.col("'>")

  if start_line == end_line then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  return {
    text = table.concat(lines, "\n"),
    start_line = start_line,
    end_line = end_line,
    start_col = start_col,
    end_col = end_col,
    replace_full_lines = false,
  }
end

-- Strip markdown code fences and trim whitespace from pi output.
local function clean_output(text)
  text = text:gsub("^%s*```%w*\n", "") -- leading fence
  text = text:gsub("\n```%s*$", "") -- trailing fence
  text = text:gsub("^%s+", ""):gsub("%s+$", "") -- trim
  return text
end

-- ┌─────────────────────────┐
-- │ edit_selection          │
-- │ <Leader>ae (visual)     │
-- └─────────────────────────┘

--- Transform a visual selection using pi -p.
--- Pi has access to `read` for optional file context, but cannot edit files.
--- The result replaces the selection directly.
function M.edit_selection()
  local sel = get_selection()
  if not sel then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "Pi edit instruction: " }, function(instruction)
    if not instruction or instruction == "" then
      return
    end

    local filepath = vim.fn.expand("%:p")

    -- Determine the indentation context from the first line of the selection
    local first_line_indent = sel.text:match("^(%s*)") or ""

    local prompt = string.format(
      [[You are a precise code editor. Transform the provided code according to the instruction.

File: %s
If you need more context, use the `read` tool to read the file.

Code:
%s

Instruction: %s

CRITICAL RULES:
1. Preserve the EXACT existing indentation level. The surrounding code uses indentation like this:
   "%s"
   Match this indentation style precisely. Do NOT change indentation depth or style.
2. Preserve all leading/trailing whitespace of unchanged lines.
3. Output ONLY the transformed code. Do NOT wrap in markdown fences, do NOT add explanations.]],
      filepath,
      sel.text,
      instruction,
      first_line_indent
    )

    -- TODO: consider async via vim.fn.jobstart for non-blocking experience.
    -- Currently synchronous; acceptable for quick edits (2-10s typical).
    local result = vim.fn.system(
      { "pi", "-p", "--provider", "opencode-go", "--model", "deepseek-v4-flash", "--thinking", "off", "-t", "read" },
      prompt
    )
    if vim.v.shell_error ~= 0 then
      local err_msg = result ~= "" and result or "(no output)"
      vim.notify("pi error (exit " .. vim.v.shell_error .. "): " .. err_msg:gsub("\n+$", ""), vim.log.levels.ERROR)
      return
    end

    result = clean_output(result)

    if result == "" then
      vim.notify("pi returned empty output", vim.log.levels.WARN)
      return
    end

    local new_lines = vim.split(result, "\n", { plain = true })

    if sel.replace_full_lines then
      -- Line-wise: replace entire lines in the range
      vim.api.nvim_buf_set_lines(0, sel.start_line - 1, sel.end_line, false, new_lines)
    else
      -- Character-wise: precise replacement preserving surrounding text on first/last lines
      vim.api.nvim_buf_set_text(0, sel.start_line - 1, sel.start_col - 1, sel.end_line - 1, sel.end_col, new_lines)
    end

    vim.notify("Selection replaced (" .. #new_lines .. " lines)", vim.log.levels.INFO)
  end)
end

-- ┌─────────────────────────┐
-- │ send_to_session         │
-- │ <Leader>as (normal/v)   │
-- └─────────────────────────┘

--- Send the current file (and optional selection) to a persistent pi session.
--- Runs asynchronously via vim.fn.jobstart; does not block neovim.
--- @param opts { selection: {text, start_line, end_line}|nil }
function M.send_to_session(opts)
  opts = opts or {}
  local selection = opts.selection

  vim.ui.input({ prompt = "Send to pi: " }, function(instruction)
    if not instruction or instruction == "" then
      return
    end

    local filepath = vim.fn.expand("%:p")
    local message = string.format("File: %s\nInstruction: %s", filepath, instruction)

    if selection then
      message = message
        .. string.format(
          "\n\nSelected text (lines %d-%d):\n%s",
          selection.start_line,
          selection.end_line,
          selection.text
        )
    end

    local session_file = session_path()

    local job_id = vim.fn.jobstart({ "pi", "-p", "--session", session_file }, {
      on_exit = function(_, exit_code)
        vim.schedule(function()
          if exit_code == 0 then
            vim.notify("pi session updated", vim.log.levels.INFO)
          else
            vim.notify("pi session error (exit " .. tostring(exit_code) .. ")", vim.log.levels.ERROR)
          end
        end)
      end,
    })

    if job_id > 0 then
      vim.fn.chansend(job_id, message .. "\n")
      vim.fn.chanclose(job_id, "stdin")
    elseif job_id == 0 then
      vim.notify("pi: job failed to start", vim.log.levels.ERROR)
    end

    vim.notify("Sent to pi (async)…", vim.log.levels.INFO)
  end)
end

-- ┌─────────────────────────┐
-- │ open_session            │
-- │ <Leader>ao (normal)     │
-- └─────────────────────────┘

--- Open the persistent pi session in a neovim terminal split.
function M.open_session()
  local session_file = session_path()
  local escaped = vim.fn.shellescape(session_file)
  vim.cmd("split | terminal pi --session " .. escaped)
  vim.cmd("startinsert")
end

return M
