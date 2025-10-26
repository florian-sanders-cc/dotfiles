-- ┌─────────────────┐
-- │ Mini Basics     │
-- └─────────────────┘
--
-- Common configuration presets for options, mappings, and autocommands.
-- Creates window navigation (<C-hjkl>) and Insert/Command mode navigation (<M-hjkl>).

vim.schedule(function()
  require('mini.basics').setup({
    -- Manage options in 'core/options.lua' for didactic purposes
    options = { basic = false },
    mappings = {
      -- Create `<C-hjkl>` mappings for window navigation
      windows = true,
      -- Create `<M-hjkl>` mappings for navigation in Insert and Command modes
      move_with_alt = true,
    },
  })
end)

-- See `:h MiniBasics.config.options` for adjustable options
-- See `:h MiniBasics.config.mappings` for created mappings
-- See `:h MiniBasics.config.autocommands` for autocommands
