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

-- Clipboard (Helix-style: operations don't touch system clipboard by default)
opt.clipboard = ""

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
opt.tabstop = 2 -- Number of spaces for a tab
opt.softtabstop = 2 -- Number of spaces for a tab when editing
opt.shiftwidth = 2 -- Number of spaces for autoindent
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
vim.o.autoread = true
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
vim.keymap.set("n", "<Esc>", "<Cmd>noh<CR>", { desc = "Clear search highlight" })

-- Clipboard (Helix-style): explicit system clipboard access
vim.keymap.set({ "n", "v" }, "<Leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<Leader>Y", '"+y$', { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<Leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<Leader>P", '"+P', { desc = "Paste before from system clipboard" })

vim.api.nvim_create_user_command("TermHl", function(opts)
  vim.opt.encoding = "utf-8"
  -- Prevent auto-centering on click
  vim.opt.scrolloff = 0
  vim.opt.compatible = false
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.termguicolors = true
  vim.opt.showmode = false
  vim.opt.ruler = false
  vim.opt.signcolumn = no
  vim.opt.showtabline = 0
  vim.opt.laststatus = 0
  vim.o.cmdheight = 0
  vim.opt.showcmd = false
  vim.opt.scrollback = 100000
  vim.opt.clipboard:append("unnamedplus")
  local term_buf = vim.api.nvim_create_buf(true, false)
  local term_io = vim.api.nvim_open_term(term_buf, {})
  -- Map 'q' to first yank the visual selection (if any), which makes the copy selection work, and then quit.
  vim.api.nvim_buf_set_keymap(term_buf, "v", "q", "y<Cmd>qa!<CR>", {})
  -- Regular quit mapping for normal mode
  vim.api.nvim_buf_set_keymap(term_buf, "n", "q", "<Cmd>qa!<CR>", {})
  local group = vim.api.nvim_create_augroup("kitty+page", { clear = true })

  local setCursor = function()
    local max_line_nr = vim.api.nvim_buf_line_count(term_buf)
    vim.api.nvim_win_set_cursor(0, { max_line_nr, 0 })
  end

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    buffer = term_buf,
    callback = function()
      local mode = vim.fn.mode()
      if mode == "t" then
        vim.cmd.stopinsert()
        vim.schedule(setCursor)
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    pattern = "*",
    once = true,
    callback = function(ev)
      local current_win = vim.fn.win_getid()
      -- Instead of sending lines individually, concatenate them.
      local main_lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -2, false)
      local content = table.concat(main_lines, "\r\n")
      vim.api.nvim_chan_send(term_io, content .. "\r\n")

      -- Process the last line separately (without trailing \r\n)
      local last_line = vim.api.nvim_buf_get_lines(ev.buf, -2, -1, false)[1]
      if last_line then
        vim.api.nvim_chan_send(term_io, last_line)
      end
      vim.api.nvim_win_set_buf(current_win, term_buf)
      vim.api.nvim_buf_delete(ev.buf, { force = true })
      -- Use vim.defer_fn to make sure the terminal has time to process the content and the buffer is ready.
      vim.defer_fn(setCursor, 10)
    end,
  })
end, { nargs = "?", desc = "Highlights ANSI termcodes in curbuf" })
