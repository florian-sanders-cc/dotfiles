-- ┌─────────────────────┐
-- │ Yazi File Manager   │
-- └─────────────────────┘
--
-- Terminal-based file manager integration.

-- Next, map a key to open yazi.nvim
vim.keymap.set("n", "<leader>E", function()
  require("yazi").yazi()
end, { desc = "Open Yazi file manager" })

-- Mark netrw as loaded so it's not loaded at all.
-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    require("yazi").setup({
      open_for_directories = true,
    })
  end,
})
