return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    input = {
      enabled = true,
      -- Make snacks input the default for vim.ui.input
      override = true,
    },
  },
}

