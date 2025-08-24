return {
  cmd = { "stylelint-lsp", "--stdio" },
  filetypes = { "css", "less", "scss", "sugarss" },
  root_markers = {
    ".stylelintrc",
    ".stylelintrc.json",
    ".stylelintrc.yaml",
    ".stylelintrc.yml",
    ".stylelintrc.js",
    ".stylelintrc.mjs",
    "stylelint.config.js",
    "stylelint.config.mjs",
    "package.json",
  },
  settings = {
    stylelint = {
      ignoreDisables = false,
      packageManager = "npm",
      snippet = { "css", "postcss" },
    },
  },
}
