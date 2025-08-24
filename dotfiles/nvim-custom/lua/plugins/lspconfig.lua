return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      words = {
        enabled = true,
      },
    },
  },
  config = function()
    vim.lsp.config("vtsls", require("language-servers.vtsls"))
    vim.lsp.config("stylelint-lsp", require("language-servers.stylelint-ls"))

    vim.lsp.enable({ "nil", "gopls", "emmylua_ls", "rust_analyzer", "marksman", "eslint", "vtsls", "stylelint-lsp" })
  end,
  keys = {
    { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
    {
      "<leader>cA",
      function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source" },
            diagnostics = {},
          },
        })
      end,
      desc = "Source Action",
      mode = { "n", "v" },
    },
    { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", mode = { "n", "v" } },
  },
}
