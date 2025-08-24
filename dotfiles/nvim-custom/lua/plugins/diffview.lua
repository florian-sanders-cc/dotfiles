return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Open File History" },
    { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open Current File History" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>ge", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Diffview Files" },
  },
  opts = {
    enhanced_diff_hl = true,
    use_icons = true,
    show_help_hints = true,
    watch_index = true,
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      merge_tool = {
        layout = "diff3_horizontal",
        disable_diagnostics = false,
      },
      file_history = {
        layout = "diff2_horizontal",
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 35,
      },
    },
    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            follow = true,
          },
        },
      },
      win_config = {
        position = "bottom",
        height = 16,
      },
    },
  },
}
