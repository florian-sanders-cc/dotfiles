-- ┌─────────────────────┐
-- │ Mini Splitjoin      │
-- └─────────────────────┘
--
-- Split and join arguments (regions inside brackets between separators).
-- Usage: `gS` to toggle between joined and split arguments (dot-repeatable).

vim.schedule(function()
  require('mini.splitjoin').setup()
end)

-- See `:h MiniSplitjoin.gen_hook` for available hooks
