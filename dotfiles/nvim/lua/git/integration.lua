-- =====================================================
-- GIT INTEGRATION CONFIGURATION
-- Neogit and Diffview for comprehensive git workflow
-- =====================================================

-- Configure Neogit (Magit-like git interface)
require("mini.diff").setup({
  -- Delays (in ms) defining asynchronous processes
  delay = {
    -- How much to wait before update following every text change
    text_change = 200,
  },

  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Apply hunks inside a visual/operator region
    apply = "gha",

    -- Reset hunks inside a visual/operator region
    reset = "ghr",

    -- Hunk range textobject to be used inside operator
    -- Works also in Visual mode if mapping differs from apply and reset
    textobject = "gh",

    -- Go to hunk range in corresponding direction
    goto_first = "[H",
    goto_prev = "[h",
    goto_next = "]h",
    goto_last = "]H",
  },
})

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

vim.opt.fillchars:append({ diff = "" })

require("gitsigns").setup({})
