require("claudecode").setup({})

vim.keymap.set({ "n", "v" }, "<leader>aA", "<Cmd>ClaudeCodeDiffAccept<CR>", { desc = "AI: Claude Accept Diff" })
vim.keymap.set({ "n", "v" }, "<leader>aD", "<Cmd>ClaudeCodeDiffDeny<CR>", { desc = "AI: Claude Deny Diff" })
