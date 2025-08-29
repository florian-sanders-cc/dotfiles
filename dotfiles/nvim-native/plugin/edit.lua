require("mini.align").setup({})
require("mini.surround").setup({})
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

vim.keymap.set({ "n", "x", "o" }, "gs", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "gS", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set(
  { "v", "n" },
  "<Leader>m",
  "<cmd>MCstart<cr>",
  { desc = "Create a selection for selected text or word under the cursor" }
)

vim.keymap.set({ "n", "v" }, "<leader>sr", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and Replace" })
