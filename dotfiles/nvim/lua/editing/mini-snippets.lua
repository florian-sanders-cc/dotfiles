-- ┌──────────────────────┐
-- │ Mini Snippets        │
-- └──────────────────────┘
--
-- Manage and expand snippets.
-- Usage: Type snippet prefix and press <C-j> to expand
--        Navigate tabstops with <C-l> (next) and <C-h> (previous)
--        Force end session with <C-c>

vim.schedule(function()
  -- Define language patterns for 'friendly-snippets'
  local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    markdown_inline = { 'markdown.json' },
  }

  local snippets = require('mini.snippets')
  local config_path = vim.fn.stdpath('config')
  snippets.setup({
    snippets = {
      -- Always load 'snippets/global.json' from config directory
      snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
      -- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })

  -- Uncomment to show snippets as completion candidates (requires LSP server):
  -- MiniSnippets.start_lsp_server()
end)

-- Snippet navigation keymaps are built-in:
-- - <C-j> - expand snippet or show picker
-- - <C-l> - jump to next tabstop
-- - <C-h> - jump to previous tabstop
-- - <C-c> - force end snippet session

-- See `:h MiniSnippets-overview` for how the module works
-- See `:h MiniSnippets-session` for snippet session details
-- See `:h MiniSnippets.gen_loader` for available loaders
