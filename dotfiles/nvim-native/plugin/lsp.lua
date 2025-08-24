local live_rename = require("live-rename")
live_rename.setup({})
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
vim.keymap.set({ "n", "v" }, "<leader>cr", live_rename.rename, { desc = "Rename" })
