-- ┌─────────────────────┐
-- │ Flash Navigation    │
-- └─────────────────────┘
--
-- Enhanced search and movement with labels.

-- Flash (search and movement)
vim.keymap.set({ "n", "x", "o" }, "ss", function()
  require("flash").jump()
end, { desc = "Flash" })
