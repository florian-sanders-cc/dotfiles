-- ┌─────────────────┐
-- │ Mini Diff       │
-- └─────────────────┘
--
-- Work with diff hunks (difference between buffer text and Git index).
-- Provides summary info used in 'mini.statusline'.

vim.schedule(function()
  require('mini.diff').setup({
    view = {
      -- Visualization style. Possible values are 'sign' and 'number'.
      -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
      style = 'sign',

      -- Signs used for hunks with 'sign' view
      signs = { add = '▒', change = '▒', delete = '▒' },

      -- Priority of used visualization extmarks
      priority = 199,
    }
  })
end)

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end

nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Git: Toggle Overlay')

-- Hunk operators (work with motions/textobjects):
-- - `ghip` - apply hunks inside paragraph
-- - `gHG` - reset hunks from cursor to end of buffer
-- - `ghgh` - apply hunk at cursor
-- - `gHgh` - reset hunk at cursor

-- See `:h MiniDiff-overview` for how the module works
-- See `:h MiniDiff-diff-summary` for available summary information
-- See `:h MiniDiff.gen_source` for built-in sources
