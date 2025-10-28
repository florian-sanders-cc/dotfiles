-- =====================================================
-- CORE NEOVIM OPTIONS & UTILITIES
-- =====================================================

local opt = vim.opt

-- ┌─────────────────────────┐
-- │ Core Setup & Leaders    │
-- └─────────────────────────┘

-- Initialize Config global for autocmds and utilities
_G.Config = {}
local gr = vim.api.nvim_create_augroup("custom-config", {})
_G.Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- Leader keys (set early, but also in keymaps.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable project-local config (with security)
opt.exrc = true
opt.secure = true -- Temporarily disable for testing

-- ┌─────────────────────────┐
-- │ Editor Options          │
-- └─────────────────────────┘

-- Mouse
opt.mouse = "" -- Disable mouse

-- Clipboard
opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- Shell
opt.shell = vim.env.SHELL or "/usr/bin/sh"
opt.shellcmdflag = "-c"
opt.shellquote = '"'
opt.shellxquote = ""
-- opt.winborder = "shadow"

-- Indentation
opt.autoindent = true -- Enable auto indentation
opt.breakindent = true -- Enable break indent
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 4 -- Number of spaces for a tab
opt.softtabstop = 4 -- Number of spaces for a tab when editing
opt.shiftwidth = 4 -- Number of spaces for autoindent
opt.shiftround = true -- Round indent to multiple of shiftwidth

-- ┌─────────────────────────┐
-- │ Files & Persistence     │
-- └─────────────────────────┘

-- Files and backups
opt.swapfile = false -- Disable swap files
opt.undofile = true -- Enable persistent undo
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Directory for undo files
opt.autoread = true -- Auto-reload files when changed externally

-- Completion
opt.completeopt = { "menuone", "popup", "noinsert" } -- Completion menu options

-- Enable filetype detection
vim.cmd.filetype("plugin indent on")

-- ┌─────────────────────────┐
-- │ Search & UI             │
-- └─────────────────────────┘

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if uppercase used
opt.hlsearch = true -- Highlight search results
opt.inccommand = "split" -- Live preview of substitutions

-- Line numbers
opt.number = true -- Show absolute line numbers
opt.relativenumber = false -- Disable relative line numbers

-- Scrolling and cursor
opt.scrolloff = 10 -- Keep 10 lines above/below cursor (LazyVim uses 10, native used 8)
opt.wrap = false -- Disable line wrapping

-- Window splits
opt.splitbelow = true -- Open horizontal splits below
opt.splitright = true -- Open vertical splits to the right

-- Fill characters for various UI elements
opt.fillchars = {
  fold = "･", -- Folded text indicator
  diff = "╱", -- Diff mode separator
}

opt.foldopen = "mark,quickfix,search,tag,undo"

-- ┌─────────────────────────┐
-- │ Mini.misc Utilities     │
-- └─────────────────────────┘

-- Various helpful utilities: auto root, restore cursor, termbg sync
require("mini.misc").setup()

-- Change current working directory based on the current file path.
-- Searches up the file tree until the first root marker ('.git' or 'Makefile')
-- and sets their parent directory as current directory.
MiniMisc.setup_auto_root()

-- Restore latest cursor position on file open
MiniMisc.setup_restore_cursor()

-- Synchronize terminal emulator background with Neovim's background
MiniMisc.setup_termbg_sync()

-- ┌─────────────────────────┐
-- │ Autocmds                │
-- └─────────────────────────┘

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 170 })
  end,
  group = highlight_group,
})

-- Auto-reload files when changed externally
autocmd({ "FocusGained", "BufEnter" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})

-- ┌─────────────────────────┐
-- │ Keymaps                 │
-- └─────────────────────────┘

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("wr", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap_leader("wz", "<Cmd>lua MiniMisc.zoom()<CR>", "Zoom toggle")
