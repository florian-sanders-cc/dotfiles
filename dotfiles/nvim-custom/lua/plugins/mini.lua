return {
  "echasnovski/mini.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require("mini.ai").setup({ n_lines = 500 })

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require("mini.surround").setup({
      mappings = {
        add = "csa", -- Add surrounding in Normal and Visual modes
        delete = "csd", -- Delete surrounding
        find = "csf", -- Find surrounding (to the right)
        find_left = "csF", -- Find surrounding (to the left)
        highlight = "csh", -- Highlight surrounding
        replace = "csr", -- Replace surrounding
        update_n_lines = "csn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    })

    require("mini.files").setup({
      options = {
        use_as_default_explorer = false,
      },
    })

    require("mini.align").setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    -- local statusline = require 'mini.statusline'
    -- -- set use_icons to true if you have a Nerd Font
    -- statusline.setup { use_icons = true }
  end,
  keys = {
    {
      "<leader>F",
      function()
        require("mini.files").open()
      end,
      desc = "Mini files",
    },
  },
}
