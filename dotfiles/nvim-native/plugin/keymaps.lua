-- =====================================================
-- CORE KEYMAPS (Non-plugin specific)
-- Plugin-specific keymaps should be defined in their respective plugin config files
-- =====================================================

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Terminal mode escape
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Better j/k movement with wrap
vim.keymap.set("n", "j", function()
  return tonumber(vim.v.count) > 0 and "j" or "gj"
end, { expr = true, silent = true, desc = "Move down (display lines)" })
vim.keymap.set("n", "k", function()
  return tonumber(vim.v.count) > 0 and "k" or "gk"
end, { expr = true, silent = true, desc = "Move up (display lines)" })

-- Center screen on scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save file
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })

-- Window splits
vim.keymap.set("n", "<Leader>_", "<cmd>vsplit<CR>", { silent = true, desc = "Vertical split" })
vim.keymap.set("n", "<Leader>-", "<cmd>split<CR>", { silent = true, desc = "Horizontal split" })

-- Better paste and yank
vim.keymap.set("v", "<Leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set("x", "y", '"+y', { silent = true, desc = "Copy to system clipboard" })

-- Change directory to current file
vim.keymap.set("n", "<leader>cd", function()
  vim.fn.chdir(vim.fn.expand("%:p:h"))
end, { desc = "Change to file directory" })

require("which-key").add({
  -- Main groups
  { "<leader>a", group = "[A]I/Claude Code" },
  { "<leader>a_", hidden = true },
  { "<leader>b", group = "[B]uffer" },
  { "<leader>b_", hidden = true },
  { "<leader>c", group = "[C]ode" },
  { "<leader>c_", hidden = true },
  { "<leader>f", group = "[F]ind" },
  { "<leader>f_", hidden = true },
  { "<leader>g", group = "[G]it" },
  { "<leader>g_", hidden = true },
  { "<leader>o", group = "[O]cto (GitHub)" },
  { "<leader>o_", hidden = true },
  { "<leader>q", group = "[Q]uit/Session" },
  { "<leader>q_", hidden = true },
  { "<leader>s", group = "[S]earch" },
  { "<leader>s_", hidden = true },
  { "<leader>u", group = "[U]I/Toggle" },
  { "<leader>u_", hidden = true },
  { "<leader>x", group = "Diagnostics/Trouble" },
  { "<leader>x_", hidden = true },

  -- Single key items
  { "<leader>D", desc = "Dashboard" },
  { "<leader>e", desc = "File Explorer" },
  { "<leader>n", desc = "Notifications" },

  -- Visual mode specific
  {
    mode = { "v" },
    { "<leader>h", group = "Git [H]unk" },
    { "<leader>h_", hidden = true },
  },
})

-- =====================================================
-- NOTE: Plugin-specific keymaps will be defined in their respective plugin files:
-- - snacks.nvim keymaps -> dotfiles/nvim-native/plugin/snacks.lua
-- - LSP keymaps -> dotfiles/nvim-native/plugin/lsp.lua
-- - Git keymaps -> dotfiles/nvim-native/plugin/git.lua
-- etc.
-- =====================================================
