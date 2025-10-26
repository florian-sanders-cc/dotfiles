-- ┌──────────────────────────┐
-- │ Terminal                 │
-- └──────────────────────────┘
--
-- Terminal keymaps for opening terminal windows.

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end

nmap_leader('tT', '<Cmd>horizontal term<CR>', 'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical term<CR>', 'Terminal (vertical)')
