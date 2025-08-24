return {
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>cr",
        function()
          local inc_rename = require("inc_rename")
          return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename (inc-rename.nvim)",
      },
    },
    opts = {},
  },

  --- Noice integration
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    optional = true,
    opts = {
      presets = { inc_rename = true },
    },
  },
}
