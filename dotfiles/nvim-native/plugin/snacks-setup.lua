-- =====================================================
-- SNACKS.NVIM SETUP
-- Multi-feature plugin providing picker, explorer, dashboard, etc.
-- =====================================================

-- Import all snacks module configurations
local picker = require("snacks-config.picker")
local buffers = require("snacks-config.buffers")
local explorer = require("snacks-config.explorer")
local ui = require("snacks-config.ui")

-- Helper function to apply keymaps
local function apply_keymaps(keymaps)
  for _, keymap in ipairs(keymaps) do
    local modes = keymap[1]
    local lhs = keymap[2]
    local rhs = keymap[3]
    local opts = keymap[4] or {}

    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

-- Merge all configs
local config = vim.tbl_deep_extend("force",
  picker.config,
  buffers.config,
  explorer.config,
  ui.config
)

-- Set up snacks with merged configuration
require("snacks").setup(config)

-- Apply all keymaps
apply_keymaps(picker.keymaps)
apply_keymaps(buffers.keymaps)
apply_keymaps(explorer.keymaps)
apply_keymaps(ui.keymaps)
