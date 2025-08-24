return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context",
    setup = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false, -- Enable multiwindow support.
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 5, -- Maximum number of lines to show for a single context
      trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
  },
  -- Don't run TSUpdate since we use Nix-provided parsers
  build = false,
  opts = {
    -- Use only Nix-provided parsers, disable installation
    ensure_installed = {},
    auto_install = false,

    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { "ruby" },
    },
    indent = { enable = true, disable = { "ruby" } },

    -- Enable treesitter-based folding
    fold = {
      enable = true,
    },

    -- Incremental selection based on treesitter
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<M-o>", -- Start selection with Alt+O
        node_incremental = "<M-o>", -- Expand with Alt+O
        node_decremental = "<M-i>", -- Shrink with Alt+I
        scope_incremental = "<M-n>", -- Expand scope with Alt+N
      },
    },
  },
  config = function(_, opts)
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup(opts)
  end,
}
