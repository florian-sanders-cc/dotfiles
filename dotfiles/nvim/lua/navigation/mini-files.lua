-- ┌─────────────────┐
-- │ Mini Files      │
-- └─────────────────┘
--
-- Navigate and manipulate file system with column view (Miller columns).
-- Press `g?` inside explorer to see all mappings.

vim.schedule(function()
  -- Enable directory/file preview
  require('mini.files').setup({ windows = { preview = true } })
end)

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end

local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>', 'Directory')
nmap_leader('ef', explore_at_file, 'File directory')
