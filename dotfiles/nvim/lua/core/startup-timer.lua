-- =====================================================
-- STARTUP TIMER INITIALIZATION
-- This file runs first (00- prefix) to capture startup time as early as possible
-- =====================================================

-- Initialize startup timing immediately
-- if not vim.g.start_time then
--   vim.g.start_time = vim.fn.reltime()
-- end

-- Function to show startup stats in floating window
local function show_startup_stats()
  local stats = require("lib.startup-stats")
  local section = stats.startup_section()

  -- Create lines for the floating window
  local lines = {}
  for _, item in ipairs(section) do
    table.insert(lines, item.text)
  end

  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.max(unpack(vim.tbl_map(string.len, lines))) + 4
  local height = #lines

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    width = width,
    height = height,
    row = 1,
    col = 0,
    style = "minimal",
    border = "rounded",
    title = " Startup Stats ",
    title_pos = "center",
  })

  -- Close on any key press
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, desc = "Close startup stats window" })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close startup stats window" })
end

-- Create user command for startup stats
vim.api.nvim_create_user_command("StartupStats", show_startup_stats, {
  desc = "Show Neovim startup statistics in a floating window",
})
if vim.env.PROF then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("StartupTimer", { clear = true }),
    callback = function()
      require("snacks.profiler").start({})
    end,
  })
end
