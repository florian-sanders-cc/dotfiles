require("mini.align").setup({})
require("mini.surround").setup({})
require("mini.pairs").setup({})
require("quicker").setup({
  opts = {
    buflisted = true,
    number = false,
    relativenumber = false,
    signcolumn = "auto",
    winfixheight = false,
    wrap = false,
  },
  highlight = {
    -- Use treesitter highlighting
    treesitter = true,
    -- Use LSP semantic token highlighting
    lsp = false,
    -- Load the referenced buffers to apply more accurate highlights (may be slow)
    load_buffers = true,
  },
  -- Set to false to disable the default options in `opts`
  use_default_opts = false,
  -- How to trim the leading whitespace from results. Can be 'all', 'common', or false
  trim_leading_whitespace = "common",
  -- Maximum width of the filename column
  max_filename_width = function()
    return math.floor(math.min(35, vim.o.columns / 2))
  end,
  -- How far the header should extend to the right
  header_length = function(type, start_col)
    return vim.o.columns - start_col
  end,
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})
require("multicursors").setup({
  hint_config = {
    float_opts = {
      border = "rounded",
    },
    position = "bottom-right",
  },
  generate_hints = {
    normal = true,
    insert = true,
    extend = true,
    config = {
      column_count = 1,
    },
  },
})
require("markdown").setup({
  mappings = {
    inline_surround_toggle = "<leader>mgs", -- (string|boolean) toggle inline style
    inline_surround_toggle_line = "<leader>mgss", -- (string|boolean) line-wise toggle inline style
    inline_surround_delete = "<leader>mds", -- (string|boolean) delete emphasis surrounding cursor
    inline_surround_change = "<leader>mcs", -- (string|boolean) change emphasis surrounding cursor
    link_add = "<leader>mgl", -- (string|boolean) add link
    link_follow = "<leader>mgx", -- (string|boolean) follow link
    go_curr_heading = "<leader>m]c", -- (string|boolean) set cursor to current section heading
    go_parent_heading = "<leader>m]p", -- (string|boolean) set cursor to parent section heading
    go_next_heading = "<leader>m]]", -- (string|boolean) set cursor to next section heading
    go_prev_heading = "<leader>m[[", -- (string|boolean) set cursor to previous section heading
  },
})
