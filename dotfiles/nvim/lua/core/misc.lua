-- ┌──────────────────────┐
-- │ Mini Misc Utilities  │
-- └──────────────────────┘
--
-- Various helpful utilities: auto root, restore cursor, termbg sync, yank highlight

require("mini.misc").setup()

-- Change current working directory based on the current file path.
-- Searches up the file tree until the first root marker ('.git' or 'Makefile')
-- and sets their parent directory as current directory.
MiniMisc.setup_auto_root()

-- Restore latest cursor position on file open
MiniMisc.setup_restore_cursor()

-- Synchronize terminal emulator background with Neovim's background
MiniMisc.setup_termbg_sync()

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("wr", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap_leader("wz", "<Cmd>lua MiniMisc.zoom()<CR>", "Zoom toggle")

-- Highlight yanked text
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 170 })
  end,
  group = highlight_group,
})

-- Auto-reload files when changed externally
vim.o.autoread = true
autocmd({ "FocusGained", "BufEnter" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})
