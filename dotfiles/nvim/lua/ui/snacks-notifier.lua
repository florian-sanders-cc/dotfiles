-- ┌──────────────────────┐
-- │ Snacks Notifier      │
-- └──────────────────────┘
--
-- Notification system

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set({ "n", "v" }, "<Leader>" .. suffix, rhs, { desc = desc })
end

-- Notifications
nmap_leader("sn", function()
  require("snacks").notifier.show_history()
end, "Show notification history")

nmap_leader("un", function()
  require("snacks").notifier.hide()
end, "Hide notifications")

-- Config export
return {
  notifier = {
    enabled = true,
  },
}
