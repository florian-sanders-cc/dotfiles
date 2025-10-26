-- ┌─────────────────────┐
-- │ Mini Bracketed      │
-- └─────────────────────┘
--
-- Go forward/backward with square brackets for various targets.
-- Examples: ]b (next buffer), [j (previous jump), [Q (first quickfix), ]X (last conflict)

vim.schedule(function()
  require('mini.bracketed').setup()
end)

-- See `:h MiniBracketed` for mapping design and list of targets
