-- ┌──────────────────────┐
-- │ Snacks Explorer      │
-- └──────────────────────┘
--
-- File explorer using Snacks

-- File Explorer
vim.keymap.set({ "n", "v" }, "<Leader>e", function()
  require("snacks").explorer()
end, { desc = "File Explorer" })

-- Config export
return {
  explorer = {
    enabled = true,
    replace_netrw = true,
  },
}
