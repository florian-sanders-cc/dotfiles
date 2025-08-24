-- =====================================================
-- GIT INTEGRATION CONFIGURATION
-- Neogit and Diffview for comprehensive git workflow
-- =====================================================

-- Configure Neogit (Magit-like git interface)
require("neogit").setup({
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
    telescope = false, -- Using snacks picker instead
    diffview = true, -- Enable diffview integration
  },
})

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
})

require("gitsigns").setup({})

-- =====================================================
-- GIT KEYMAPS
-- =====================================================

-- Neogit
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Neogit Commit" })

-- Diffview
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Open File History" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Open Current File History" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
vim.keymap.set("n", "<leader>ge", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle Diffview Files" })

-- Note: Git picker operations (gb, gl, gL, gs, gS, gd, gf) are handled by snacks/git.lua

