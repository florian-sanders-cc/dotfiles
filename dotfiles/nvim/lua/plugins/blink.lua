return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      ghost_text = { enabled = false },
    },
    sources = {
      default = { "lsp", "path", "snippets" },
      providers = {
        buffer = { enabled = false },
      },
    },
  },
}
