-- =====================================================
-- SNACKS.NVIM SETUP
-- Multi-feature plugin providing picker, explorer, dashboard, etc.
-- =====================================================

-- Import all snacks module configurations from distributed locations
local picker = require("navigation.fuzzy-finder")
local buffers = require("navigation.buffer-manager")
local explorer = require("navigation.file-explorer")
local ui = require("ui.misc")

-- Merge all configs
local config = vim.tbl_deep_extend("force", picker, buffers, explorer, ui)

-- Set up snacks with merged configuration
require("snacks").setup(config)

-- Fire custom event to signal Snacks is loaded and configured
vim.api.nvim_exec_autocmds("User", { pattern = "SnacksLoaded" })

-- NOTE: Keymaps are now consolidated in plugin/keymaps.lua
-- UI toggles are handled via autocmd in plugin/keymaps.lua
