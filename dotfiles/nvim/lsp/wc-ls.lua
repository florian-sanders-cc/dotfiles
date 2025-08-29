return {
  cmd = { "wc-language-server", "--stdio" },
  filetypes = { "html", "javascript", "typescript" },
  root_markers = {
    "package.json",
    "wc.config.js",
    ".git",
  },
}
