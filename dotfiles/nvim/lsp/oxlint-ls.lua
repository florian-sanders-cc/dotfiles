--- @brief
---
--- https://github.com/oxc-project/oxc
---
--- `oxc` is a linter / formatter for JavaScript / Typescript supporting over 500 rules from ESLint and its popular plugins
--- It can be installed via `npm`:
---
--- ```sh
--- npm i -g oxlint
--- ```

local util = require("lspconfig.util")

---@type vim.lsp.Config
return {
  cmd = { "oxc_language_server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  init_options = {
    settings = {
      disableNestedConfig = false,
      fixKind = "safe_fix",
      run = "onType",
      typeAware = false,
      unusedDisableDirectives = "deny",
    },
  },
  settings = {
    disableNestedConfig = false,
    fixKind = "safe_fix",
    run = "onType",
    typeAware = false,
    unusedDisableDirectives = "deny",
  },
  workspace_required = true,
  root_markers = { ".oxlintrc.json" },
}
