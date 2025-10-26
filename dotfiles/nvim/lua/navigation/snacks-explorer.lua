-- ┌──────────────────────┐
-- │ Snacks Explorer      │
-- └──────────────────────┘
--
-- File explorer using Snacks

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set({ "n", "v" }, "<Leader>" .. suffix, rhs, { desc = desc })
end

-- File Explorer
nmap_leader("e", function()
  require("snacks").explorer()
end, "File Explorer")

-- Config export
return {
  explorer = {
    enabled = true,
    replace_netrw = true,
  },
}
