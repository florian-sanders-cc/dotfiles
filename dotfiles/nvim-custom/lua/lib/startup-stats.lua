-- Custom dashboard configuration with performance metrics
local M = {}

-- Function to count loaded plugins
function M.get_plugin_count()
  local lazy_ok, lazy = pcall(require, 'lazy')
  if not lazy_ok then
    return { loaded = 0, total = 0 }
  end

  local plugins = lazy.plugins()
  local loaded = 0
  local total = #plugins

  for _, plugin in ipairs(plugins) do
    if plugin._.loaded then
      loaded = loaded + 1
    end
  end

  return { loaded = loaded, total = total }
end

-- Function to get startup time
function M.get_startup_time()
  local stats = lazy.stats()
  return stats.startuptime or 0
end

-- Custom startup section
function M.startup_section()
  local plugin_info = M.get_plugin_count()
  local startup_time = M.get_startup_time()

  return {
    {
      text = string.format('󰂖 %d/%d plugins loaded', plugin_info.loaded, plugin_info.total),
      hl = 'SnacksDashboardDesc',
    },
    {
      text = string.format('󱎫 %.2fms startup time', startup_time),
      hl = 'SnacksDashboardDesc',
    },
    {
      text = string.format('󰃭 %s', vim.fn.getcwd()),
      hl = 'SnacksDashboardDesc',
    },
  }
end

return M
