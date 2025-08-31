-- =====================================================
-- CORE NEOVIM OPTIONS
-- =====================================================

local opt = vim.opt

-- Leader keys (set early, but also in keymaps.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable project-local config (with security)
opt.exrc = true
opt.secure = true -- Temporarily disable for testing

-- Mouse
opt.mouse = "" -- Disable mouse

-- Clipboard
opt.clipboard = "unnamedplus" -- Sync with system clipboard
