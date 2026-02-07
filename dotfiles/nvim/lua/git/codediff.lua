-- ┌─────────────────┐
-- │ CodeDiff        │
-- └─────────────────┘
--
-- VSCode-style side-by-side diff viewer with git integration.

require("codediff").setup({
  explorer = {
    position = "left",
    width = 35,
  },
})

-- Keymaps (same bindings as previous diffview setup)
vim.keymap.set("n", "<leader>gD", "<cmd>CodeDiff<cr>", { desc = "Git: Open CodeDiff" })
vim.keymap.set("n", "<leader>gh", "<cmd>CodeDiff history<cr>", { desc = "Git: File History" })
vim.keymap.set("n", "<leader>gH", "<cmd>CodeDiff history HEAD~50 %<cr>", { desc = "Git: Current File History" })
vim.keymap.set("n", "<leader>gq", "<cmd>tabclose<cr>", { desc = "Git: Close Diff Tab" })
