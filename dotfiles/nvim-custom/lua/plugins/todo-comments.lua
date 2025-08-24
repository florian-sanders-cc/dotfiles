return {
  'folke/todo-comments.nvim',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
  keys = {
    {
      '<leader>st',
      function()
        require('snacks').picker.todo_comments { cwd = vim.fn.expand '%:p:h' }
      end,
      desc = 'Todo Comments (Buffer)',
    },
    {
      '<leader>sT',
      function()
        require('snacks').picker.todo_comments()
      end,
      desc = 'Todo Comments (Workspace)',
    },
  },
}

