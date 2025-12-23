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
    javascript = { "prettier", stop_after_first = true },
    typescript = { "prettier", stop_after_first = true },
    json = { "prettier", stop_after_first = true },
    jsonc = { "prettier", stop_after_first = true },
  },
  formatters = {
    stylua = {
      args = { "--indent-type", "Spaces", "--indent-width", "2", "--stdin-filepath", "$FILENAME", "-" },
    },
  },
})
