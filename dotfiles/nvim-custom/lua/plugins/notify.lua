return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    notifier = {
      enabled = true,
      timeout = 3000,
      max_width = 60,
      max_height = 6,
      style = "compact",
      top_down = true,
    },
  },
  keys = {
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Hide notifications",
    },
    {
      "<leader>sn",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Show notification history",
    },
  },
}
