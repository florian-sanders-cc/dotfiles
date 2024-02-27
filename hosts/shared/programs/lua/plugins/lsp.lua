return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = {
          severity = vim.diagnostic.severity.ERROR,
        },
      },
    },
  },
}
