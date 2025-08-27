-- =====================================================
-- STARTUP TIMER INITIALIZATION
-- This file runs first (00- prefix) to capture startup time as early as possible
-- =====================================================

-- Initialize startup timing immediately
-- if not vim.g.start_time then
--   vim.g.start_time = vim.fn.reltime()
-- end

-- Store when VimEnter event fires for more detailed timing
if vim.env.PROF then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("StartupTimer", { clear = true }),
    callback = function()
      require("snacks.profiler").start({})
    end,
  })
end
