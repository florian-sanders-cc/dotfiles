require("inc_rename").setup({
  input_buffer_type = "snacks",
})

vim.lsp.enable({ "nil_ls", "gopls", "lua_ls", "rust_analyzer", "marksman", "eslint", "vtsls" })
vim.diagnostic.config({
  virtual_lines = { current_line = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set({ "n", "v" }, "<leader>cA", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source" },
      diagnostics = {},
    },
  })
end, { desc = "Source Action" })
vim.keymap.set({ "n", "v" }, "<leader>cr", ":IncRename ", { desc = "Rename" })
