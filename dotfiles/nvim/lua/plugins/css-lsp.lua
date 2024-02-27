if true then
  return {}
end
-- not sure I need this LSP for now
return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      ---@type lspconfig.options.cssls
      cssmodules_ls = {
        filetypes = {
          "css",
          "html",
          "less",
          "sass",
          "scss",
          "javascript",
          "typescript",
        },
        enabled = false,
        settings = {
          css = {
            validate = true,
          },
        },
      },
    },
  },
}
