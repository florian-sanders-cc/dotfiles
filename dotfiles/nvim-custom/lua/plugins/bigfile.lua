return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {
      enabled = true,
      size = 1024 * 1024, -- 1MB
      setup = function(ctx)
        vim.b.minianimate_disable = true
        vim.schedule(function()
          vim.bo[ctx.buf].syntax = ctx.ft
        end)
      end,
    },
  },
}

