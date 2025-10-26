-- ┌──────────────────────────┐
-- │ Mini Indentscope         │
-- └──────────────────────────┘
--
-- Visualize and work with indent scope with animated vertical line.
-- Provides motions and textobjects.

vim.schedule(function()
  require('mini.indentscope').setup({
    symbol = '│', -- ╎ │ ⋅ ┊
  })
end)

-- Usage:
-- - `cii` - change inside indent scope
-- - `Vaiai` - visually select around indent scope, then reselect around new scope
-- - `[i` / `]i` - navigate to scope's top/bottom

-- See `:h MiniIndentscope.gen_animation` for animation rules
