return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      ---@type lspconfig.options.eslint
      eslint = {
        settings = {
          options = {
            rulePaths = {
              "/home/flo/Projects/clever-components/eslint-rules",
            },
          },
          workingDirectory = {
            mode = "auto",
          },
        },
      },
    },
    setup = {
      eslint = function()
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "typescript-tools" or client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
