return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration

    -- Only one of these is needed, not both.
    "nvim-telescope/telescope.nvim", -- optional
  },
  keys = {
    { "<leader>gn", "<cmd>Neogit<CR>", mode = { "n" }, desc = "Open current status and diff" },
  },
  config = true,
}
