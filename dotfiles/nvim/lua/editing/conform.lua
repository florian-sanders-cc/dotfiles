require("conform").setup({
  notify_on_error = true,
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true }
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 500,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "nixfmt" },
    javascript = { "oxfmt", "prettier", stop_after_first = true },
    javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
    typescript = { "oxfmt", "prettier", stop_after_first = true },
    typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
    json = { "oxfmt", "prettier", stop_after_first = true },
    jsonc = { "oxfmt", "prettier", stop_after_first = true },
  },
  formatters = {
    oxfmt = {
      -- Only opt in with an Oxfmt config; other projects keep Prettier.
      cwd = require("conform.util").root_file({ ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }),
      require_cwd = true,
    },
    stylua = {
      args = { "--indent-type", "Spaces", "--indent-width", "2", "--stdin-filepath", "$FILENAME", "-" },
    },
  },
})
