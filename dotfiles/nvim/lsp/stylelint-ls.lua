return {
  cmd = { "stylelint-ls", "--stdio" },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(0, "LspStylelintFixAll", function()
      client:request_sync("workspace/executeCommand", {
        command = "stylelint.applyAutoFix",
        arguments = {
          {
            uri = vim.uri_from_bufnr(bufnr),
            version = vim.lsp.util.buf_versions[bufnr],
          },
        },
      }, nil, bufnr)
    end, {})
  end,
  filetypes = { "css", "less", "scss", "sugarss" },
  root_markers = {
    ".stylelintrc",
    ".stylelintrc.json",
    ".stylelintrc.yaml",
    ".stylelintrc.yml",
    ".stylelintrc.js",
    ".stylelintrc.mjs",
    "stylelint.config.js",
    "stylelint.config.mjs",
    "package.json",
  },
  settings = {
    stylelint = {
      ignoreDisables = false,
      packageManager = "npm",
      snippet = { "css", "postcss" },
    },
  },
}
