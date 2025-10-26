-- ┌──────────────────────┐
-- │ Snacks Bufdelete     │
-- └──────────────────────┘
--
-- Buffer deletion utilities

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

-- Buffer management (<leader>b)
nmap_leader("bd", function()
  require("snacks").bufdelete()
end, "Delete current buffer")

nmap_leader("ba", function()
  require("snacks").bufdelete.all()
end, "Delete all buffers")

nmap_leader("bo", function()
  require("snacks").bufdelete.other()
end, "Delete other buffers")

-- Register with which-key (descriptions are already in keymap.set above)
-- No additional registration needed - vim.keymap.set with desc automatically registers!

-- Config export
return {
  bufdelete = {
    enabled = true,
  },
}
