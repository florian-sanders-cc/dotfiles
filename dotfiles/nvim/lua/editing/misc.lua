-- =====================================================
-- MISC EDITING OPTIONS
-- =====================================================

-- Indentation
vim.opt.autoindent = true -- Enable auto indentation
vim.opt.breakindent = true -- Enable break indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 4 -- Number of spaces for a tab
vim.opt.softtabstop = 4 -- Number of spaces for a tab when editing
vim.opt.shiftwidth = 4 -- Number of spaces for autoindent
vim.opt.shiftround = true -- Round indent to multiple of shiftwidth

-- Files and backups
vim.opt.swapfile = false -- Disable swap files
vim.opt.undofile = true -- Enable persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Directory for undo files

-- Completion
vim.opt.completeopt = { "menuone", "popup", "noinsert" } -- Completion menu options

-- Enable filetype detection
vim.cmd.filetype("plugin indent on")

-- Search
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Override ignorecase if uppercase used
vim.opt.hlsearch = true -- Highlight search results
vim.opt.inccommand = "split" -- Live preview of substitutions

-- Scrolling and cursor
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor (LazyVim uses 10, native used 8)
vim.opt.wrap = false -- Disable line wrapping
