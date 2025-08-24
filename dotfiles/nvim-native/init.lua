-- =====================================================
-- CORE NEOVIM OPTIONS
-- Merged from LazyVim config with native preferences
-- =====================================================

local opt = vim.opt

-- Leader keys (set early, but also in keymaps.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable project-local config (with security)
opt.exrc = true
opt.secure = true -- Temporarily disable for testing

-- Font and UI
vim.g.have_nerd_font = true

-- Line numbers
opt.number = true
opt.relativenumber = false
opt.numberwidth = 2

-- Display and appearance
opt.conceallevel = 0 -- Always show all text, no conceal
-- opt.showmode = false      -- Don't show mode (in statusline already)
vim.o.laststatus = 3
opt.cmdheight = 0 -- Hide command line when not used
opt.cursorline = true -- Highlight current line
opt.signcolumn = "yes:1" -- Always show sign column
opt.termguicolors = true -- Enable true colors
opt.winborder = "rounded" -- Rounded borders for windows

-- Mouse
opt.mouse = "" -- Disable mouse

-- Clipboard
opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- Indentation
opt.autoindent = true -- Enable auto indentation
opt.breakindent = true -- Enable break indent
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 4 -- Number of spaces for a tab
opt.softtabstop = 4 -- Number of spaces for a tab when editing
opt.shiftwidth = 4 -- Number of spaces for autoindent
opt.shiftround = true -- Round indent to multiple of shiftwidth

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if uppercase used
opt.hlsearch = true -- Highlight search results
opt.inccommand = "split" -- Live preview of substitutions

-- Files and backups
opt.swapfile = false -- Disable swap files
opt.undofile = true -- Enable persistent undo
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Directory for undo files

-- Splits
opt.splitright = true -- Vertical splits to the right
opt.splitbelow = true -- Horizontal splits below

-- Scrolling and cursor
opt.scrolloff = 10 -- Keep 10 lines above/below cursor (LazyVim uses 10, native used 8)
opt.wrap = false -- Disable line wrapping

-- Whitespace display
opt.list = false -- Show whitespace characters (LazyVim enables, native disables)
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Whitespace characters

-- Timing
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 300 -- Shorter timeout for which-key

-- Completion
opt.completeopt = { "menuone", "popup", "noinsert" } -- Completion menu options

-- Enable filetype detection
vim.cmd.filetype("plugin indent on")

-- Set colorscheme
vim.cmd.colorscheme("nordic")

-- Only enable extui for nvim 0.12+
if vim.fn.has("nvim-0.12") == 1 then
  require("vim._extui").enable({})
end
