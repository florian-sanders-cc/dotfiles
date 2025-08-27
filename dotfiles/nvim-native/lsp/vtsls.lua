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
    complete_function_calls = true,
    enableMoveToFileCodeAction = true,
    autoUseWorkspaceTsdk = true,
    tsserver = {
      maxTsServerMemory = 8192,
    },
    experimental = {
      completion = {
        enableServerSideFuzzyMatch = true,
        entriesLimit = 50,
      },
    },
    typescript = {
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
