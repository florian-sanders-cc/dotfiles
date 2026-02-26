return {
  cmd = { "cem", "lsp" },
  root_markers = { "custom-elements.json", "package.json", ".git" },
  filetypes = { "html", "typescript", "javascript" },
  -- Control debug logging via LSP trace levels
  trace = "off", -- 'off' | 'messages' | 'verbose'
}
