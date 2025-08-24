return {
  'brenton-leighton/multiple-cursors.nvim',
  version = '*', -- Use the latest tagged version
  opts = {
    match_visible_only = false,
    custom_key_maps = {
      {
        'n',
        'gl',
        function()
          require('multiple-cursors').align()
        end,
      },
    },
  }, -- This causes the plugin setup function to be called
  keys = {
    { 'gj', '<Cmd>MultipleCursorsAddDown<CR>', mode = { 'n', 'x' }, desc = 'Add cursor and move down' },
    { 'gk', '<Cmd>MultipleCursorsAddUp<CR>', mode = { 'n', 'x' }, desc = 'Add cursor and move up' },

    { 'g<Up>', '<Cmd>MultipleCursorsAddUp<CR>', mode = { 'n', 'i', 'x' }, desc = 'Add cursor and move up' },
    { 'g<Down>', '<Cmd>MultipleCursorsAddDown<CR>', mode = { 'n', 'i', 'x' }, desc = 'Add cursor and move down' },

    {
      'g<LeftMouse>',
      '<Cmd>MultipleCursorsMouseAddDelete<CR>',
      mode = { 'n', 'i' },
      desc = 'Add or remove cursor',
    },

    { 'ga', '<Cmd>MultipleCursorsAddMatches<CR>', mode = { 'n', 'x' }, desc = 'Add cursors to cword' },
    {
      'gA',
      '<Cmd>MultipleCursorsAddMatchesV<CR>',
      mode = { 'n', 'x' },
      desc = 'Add cursors to cword in previous area',
    },
    {
      'gn',
      '<Cmd>MultipleCursorsAddJumpNextMatch<CR>',
      mode = { 'n', 'x' },
      desc = 'Add cursor and jump to next cword',
    },
    { 'gN', '<Cmd>MultipleCursorsJumpNextMatch<CR>', mode = { 'n', 'x' }, desc = 'Jump to next cword' },

    { 'gL', '<Cmd>MultipleCursorsLock<CR>', mode = { 'n', 'x' }, desc = 'Lock virtual cursors' },
  },
}
