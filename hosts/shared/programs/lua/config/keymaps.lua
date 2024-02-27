-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- position cursor at the end of the word in Insert mode
vim.keymap.set("n", "<a-a>", "ce<c-r>-")
