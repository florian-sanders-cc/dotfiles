return {
  "NeogitOrg/neogit",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
  },
  opts = {
    auto_refresh = true,
    disable_hint = false,
    disable_context_highlighting = false,
    disable_signs = false,
    graph_style = "unicode",
    console_timeout = 2000,
    filewatcher = {
      interval = 1000,
      enabled = true,
    },
    integrations = {
      telescope = false,
      diffview = true,
    },
  },
}

