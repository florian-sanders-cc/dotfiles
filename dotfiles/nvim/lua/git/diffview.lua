-- ┌─────────────────┐
-- │ Diffview        │
-- └─────────────────┘
--
-- Git diff viewer with file history.

-- Configure Diffview (Git diff viewer)
require("diffview").setup({
  enhanced_diff_hl = true,
  use_icons = true,
  show_help_hints = true,
  watch_index = true,
  view = {
    default = {
      layout = "diff2_horizontal",
    },
    merge_tool = {
      layout = "diff3_mixed",
      disable_diagnostics = false,
      winbar_info = true,
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
})

-- Ensure fillchars are set correctly after all plugins load
vim.schedule(function()
  vim.opt.fillchars:append({ fold = " ", diff = "" })
end)

-- Keymaps
-- Diffview
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Git: Open Diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Git: File History" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git: Current File History" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Git: Close Diffview" })
vim.keymap.set("n", "<leader>ge", "<cmd>DiffviewToggleFiles<cr>", { desc = "Git: Toggle Files Panel" })
