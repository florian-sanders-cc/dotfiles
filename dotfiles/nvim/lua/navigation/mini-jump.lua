-- ┌─────────────────────┐
-- │ Mini Jump           │
-- └─────────────────────┘
--
-- Jump to next/previous single character across multiple lines.
-- Implements "smarter fFtT keys" with jumping mode and target highlighting.

vim.schedule(function()
  require('mini.jump').setup()
end)

-- Usage:
-- - `fxff` - move forward onto next "x", then next, and next again
-- - `dt)` - delete till next closing parenthesis

-- See `:h f`, `:h F`, `:h t`, `:h T` for built-in equivalents
