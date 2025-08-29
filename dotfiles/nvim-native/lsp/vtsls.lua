---@type vim.lsp.Config
return {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    enableMoveToFileCodeAction = true,
    vtsls = {
      autoUseWorkspaceTsdk = true,
      enableMoveToFileCodeAction = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
          entriesLimit = 50,
        },
      },
    },
    tsserver = {
      maxTsServerMemory = 8192,
    },
    typescript = {
      suggest = {
        completeFunctionCalls = true,
      },
      preferences = {
        importModuleSpecifier = "relative",
        includePackageJsonAutoImports = "off",
        useAliasesForRenames = false,
        format = {
          enable = false,
        },
      },
    },
    javascript = {
      suggest = {
        completeFunctionCalls = true,
      },
      preferences = {
        importModuleSpecifier = "relative",
        includePackageJsonAutoImports = "off",
        useAliasesForRenames = false,
        format = {
          enable = false,
        },
      },
    },
  },
}
