return {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
  opts = {},
  keys = {
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete current buffer',
    },
    {
      '<leader>ba',
      function()
        Snacks.bufdelete.all()
      end,
      desc = 'Delete all buffers',
    },
    {
      '<leader>bo',
      function()
        Snacks.bufdelete.other()
      end,
      desc = 'Delete other buffers',
    },
  },
}
