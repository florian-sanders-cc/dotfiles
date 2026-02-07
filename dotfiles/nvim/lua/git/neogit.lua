-- ┌─────────────────┐
-- │ Neogit          │
-- └─────────────────┘
--
-- Magit-like git interface for Neovim.

require("neogit").setup({
  auto_refresh = true,
  disable_hint = false,
  disable_context_highlighting = false,
  disable_signs = false,
  graph_style = "unicode",
  console_timeout = 2000,
  filewatcher = {
    interval = 1000,
    enabled = true,
  },
  integrations = {
    telescope = false, -- Using snacks picker instead
    diffview = false,
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Git: Open Neogit" })
vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Git: Commit" })
