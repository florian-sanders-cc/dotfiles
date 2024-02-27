local HOME = os.getenv("HOME")

-- vim.lsp.set_log_level("debug")

return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    servers = {
      ---@type lspconfig.options.tsserver
      tsserver = {
        on_new_config = function(new_config, new_root_dir)
          if string.find(new_root_dir, "console3") then
            new_config.init_options = {
              hostInfo = "neovim",
              tsserver = {
                path = HOME .. "/.volta/tools/image/packages/typescript/lib/node_modules/typescript/lib/tsserver.js",
              },
            }
          end
        end,
        settings = {
          implicitProjectConfiguration = { checkJs = true, allowJs = true },
          fallbackPath = HOME .. ".volta/tools/image/packages/typescript/lib/node_modules/typescript/lib/tsserver.js",
          importModuleSpecifierEnding = "js",
          tsserver_plugins = {},
          javascript = {
            validate = {
              enabled = true,
            },
            preferences = {
              quoteStyle = "single",
              renameMatchingJsxTags = true,
            },
            format = {
              enable = true,
              semicolons = "insert",
              insertSpaceBeforeFunctionParenthesis = true,
            },
            suggest = {
              completeFunctionCalls = false,
            },
            updateImportsOnFileMove = true,
            preferGoToSourceDefinition = true,
          },
        },
      },
    },
  },
}
