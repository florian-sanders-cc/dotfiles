-- ┌─────────────────┐
-- │ Mini Starter    │
-- └─────────────────┘
--
-- Start screen shown when opening Neovim without a file.

vim.schedule(function()
  require('mini.starter').setup()
end)

-- See `:h MiniStarter-example-config` for customization examples
