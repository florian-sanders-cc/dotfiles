require("inc_rename").setup({
  input_buffer_type = "snacks",
})

vim.lsp.enable({ "nil_ls", "gopls", "emmylua_ls", "rust_analyzer", "marksman", "eslint", "vtsls" })
vim.diagnostic.config({ virtual_text = false })

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set({ "n", "v" }, "<leader>cA", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source" },
      diagnostics = {},
    },
  })
end, { desc = "Source Action" })
vim.keymap.set({ "n", "v" }, "<leader>rn", ":IncRename ", { desc = "Rename" })
