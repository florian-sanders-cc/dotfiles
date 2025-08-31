local base_stylelint_on_attach = vim.lsp.config["stylelint-ls"].on_attach
vim.lsp.config("stylelint-ls", {
  filetypes = { "javascript" },
  on_attach = function(client, bufnr)
    if not base_stylelint_on_attach then
      return
    end

    base_stylelint_on_attach(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspStylelintFixAll",
    })
  end,
  settings = {
    stylelint = {
      validate = { "javascript" },
      ignoreDisables = false,
      packageManager = "npm",
      snippet = { "css", "postcss" },
      customSyntax = "postcss-styled-syntax",
    },
  },
})

vim.lsp.enable("stylelint-ls")
