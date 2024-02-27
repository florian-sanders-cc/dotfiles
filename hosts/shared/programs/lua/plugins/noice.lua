return {
  -- https://github.com/folke/noice.nvim
  {
    "folke/noice.nvim",
    opts = {
      -- presets = {
      --   lsp_doc_border = true,
      -- },
      views = {
        hover = {
          border = {
            style = "none",
            padding = { 1, 2 },
          },
          position = { row = 2, col = 0 },
        },
      },
      lsp = {
        hover = {
          -- Set not show a message if hover is not available
          -- ex: shift+k on Typescript code
          silent = true,
        },
      },
    },
  },
}
