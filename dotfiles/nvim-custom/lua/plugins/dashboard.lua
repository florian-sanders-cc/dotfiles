return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      enabled = true,
      preset = {},
      sections = {
        { section = 'header' },
        { section = 'session' },
        {
          section = 'startup',
          padding = 1,
          fn = function()
            local dashboard = require 'lib.startup-stats'
            return dashboard.startup_section()
          end,
        },
      },
    },
  },
  init = function()
    -- Show dashboard on startup if no files are opened
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        if vim.fn.argc() == 0 then
          Snacks.dashboard()
        end
      end,
    })
  end,
  keys = {
    {
      '<leader>D',
      function()
        Snacks.dashboard()
      end,
      desc = 'Dashboard',
    },
  },
}
