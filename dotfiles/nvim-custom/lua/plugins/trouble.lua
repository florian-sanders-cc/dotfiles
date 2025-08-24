return {
  'folke/trouble.nvim',
  event = 'VeryLazy',
  opts = {
    modes = {
      lsp = {
        win = { position = 'right' },
      },
    },
    icons = {
      indent = {
        fold_open = ' ',
        fold_closed = ' ',
      },
      folder_closed = ' ',
      folder_open = ' ',
    },
  },
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
  },
}
