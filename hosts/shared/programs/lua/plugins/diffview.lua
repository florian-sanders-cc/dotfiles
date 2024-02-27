return {
  {
    "sindrets/diffview.nvim",
    cmd = "Diffview",
    keys = {
      { "<leader>gg", "<cmd>DiffviewOpen<CR>", mode = { "n" }, desc = "Open current status and diff" },
      { "<leader>gf", "<cmd>DiffviewFileHistory<CR>", mode = { "n" }, desc = "Open project history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", mode = { "n" }, desc = "Close Diffview" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase.
          layout = "diff3_mixed",
          disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
          winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
