require("octo").setup({
  enable_builtin = true,
})

vim.keymap.set({ "n", "v" }, "<leader>o", "<cmd>Octo<cr>", { desc = "Octo GitHub" })
