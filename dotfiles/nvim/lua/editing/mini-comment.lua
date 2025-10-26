-- ┌─────────────────────┐
-- │ Mini Comment        │
-- └─────────────────────┘
--
-- Comment lines using commentstring.
-- Usage: `gcip` to toggle comment inside paragraph, `gcgc` to uncomment comment block.

vim.schedule(function()
  require('mini.comment').setup()
end)

-- Note: Neovim's built-in commenting is based on mini.comment,
-- but this module provides more customization opportunities.
