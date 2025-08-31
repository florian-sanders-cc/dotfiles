-- Custom dashboard configuration with performance metrics
local M = {}

-- Function to get startup time from initialization to now
function M.get_startup_time()
  if vim.g.start_time then
    return vim.fn.reltimefloat(vim.fn.reltime(vim.g.start_time)) * 1000
  end
  return 0 -- Fallback if timing wasn't captured
end

-- Function to get startup time from initialization to VimEnter
function M.get_init_time()
  if vim.g.start_time and vim.g.vim_enter_time then
    return vim.fn.reltimefloat(vim.fn.reltime(vim.g.start_time, vim.g.vim_enter_time)) * 1000
  end
  return nil
end

-- Function to get memory usage
function M.get_memory_usage()
  local mem_kb = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub('%s+', '')
  local mem_kb_num = tonumber(mem_kb)
  
  if mem_kb_num then
    return mem_kb_num / 1024
  else
    -- Fallback: try alternative method or return 0
    return 0
  end
end

-- Custom startup section
function M.startup_section()
  local memory_mb = M.get_memory_usage()
  local init_time = M.get_init_time()
  local current_time = M.get_startup_time()
  
  local result = {}
  
  -- Show initialization time (to VimEnter) if available
  if init_time then
    table.insert(result, {
      text = string.format('󱎫 %.1fms init time', init_time),
      hl = 'SnacksDashboardDesc',
    })
  end
  
  -- Show current uptime
  table.insert(result, {
    text = string.format('󰔟 %.1fms uptime', current_time),
    hl = 'SnacksDashboardDesc',
  })
  
  -- Memory usage
  if memory_mb > 0 then
    table.insert(result, {
      text = string.format('󰍛 %.1fMB memory usage', memory_mb),
      hl = 'SnacksDashboardDesc',
    })
  else
    table.insert(result, {
      text = '󰍛 Memory usage unavailable',
      hl = 'SnacksDashboardDesc',
    })
  end
  
  -- Current working directory
  table.insert(result, {
    text = string.format('󰃭 %s', vim.fn.fnamemodify(vim.fn.getcwd(), ':~')),
    hl = 'SnacksDashboardDesc',
  })

  return result
end

return M
