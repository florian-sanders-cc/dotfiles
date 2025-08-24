return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    explorer = { enabled = true },
  },
  keys = {
    {
      '<leader>e',
      function()
        Snacks.explorer()
      end,
      desc = 'File Explorer',
    },
  },
}

