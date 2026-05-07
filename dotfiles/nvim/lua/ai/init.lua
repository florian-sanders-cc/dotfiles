-- =====================================================
-- AI KEYMAPS
-- =====================================================
--
-- Registers keymaps under the <Leader>a group (defined in ui/which-key.lua).
-- All pi integration logic lives in ai/pi.lua.

local pi = require("ai.pi")
local wk = require("which-key")

-- <Leader>ae — Edit selection with pi (visual mode only)
vim.keymap.set("v", "<Leader>ae", function()
  pi.edit_selection()
end, { desc = "Edit selection with pi" })

-- <Leader>as — Send to pi session (normal + visual)
-- Visual mode wrapper captures the selection before vim.ui.input exits visual mode.
vim.keymap.set("v", "<Leader>as", function()
  -- Capture selection immediately; get_selection reads '< and '> marks
  local sel_line_start = vim.fn.line("'<")
  local sel_line_end = vim.fn.line("'>")
  local selection = nil

  if sel_line_start > 0 and sel_line_end > 0 then
    local lines = vim.fn.getline(sel_line_start, sel_line_end)
    local mode = vim.fn.visualmode(1)

    if mode == "V" then
      selection = {
        text = table.concat(lines, "\n"),
        start_line = sel_line_start,
        end_line = sel_line_end,
      }
    else
      local start_col = vim.fn.col("'<")
      local end_col = vim.fn.col("'>")
      if sel_line_start == sel_line_end then
        lines[1] = string.sub(lines[1], start_col, end_col)
      else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
      end
      selection = {
        text = table.concat(lines, "\n"),
        start_line = sel_line_start,
        end_line = sel_line_end,
      }
    end
  end

  pi.send_to_session({ selection = selection })
end, { desc = "Send to pi session" })

vim.keymap.set("n", "<Leader>as", function()
  pi.send_to_session({ selection = nil })
end, { desc = "Send to pi session" })

-- <Leader>ao — Open pi session in terminal split (normal mode only)
vim.keymap.set("n", "<Leader>ao", function()
  pi.open_session()
end, { desc = "Open pi session" })
