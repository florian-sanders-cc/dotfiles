-- ┌──────────────────────────┐
-- │ Which-Key Configuration  │
-- └──────────────────────────┘
--
-- Centralized setup and group definitions
-- Individual keymaps are registered in their respective plugin files

require("which-key").setup({
  preset = "helix", -- Centered vertical layout - easier to scan many keymaps
  delay = 300,
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = false, -- Disable to allow custom LSP "g" keymaps to show
    },
  },
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  win = {
    border = "solid",
    padding = { 1, 2 },
  },
  layout = {
    width = { min = 20 }, -- Minimum width
    spacing = 3, -- Spacing between columns
  },
})

-- ┌──────────────────────────────────────────┐
-- │ Leader Key Group Definitions             │
-- └──────────────────────────────────────────┘
-- Define groups only - actual keymaps are registered
-- in their respective plugin configuration files

local wk = require("which-key")

wk.add({
  { "<leader>a", group = "AI" },
  { "<leader>b", group = "Buffers" },
  { "<leader>c", group = "Code" },
  { "<leader>e", group = "Explorer" },
  { "<leader>f", group = "Find Files" },
  { "<leader>g", group = "Git" },
  { "<leader>Gh", group = "Github" },
  { "<leader>Ghc", group = "Github: Commit" },
  { "<leader>Ghi", group = "Github: Issue" },
  { "<leader>Ghl", group = "Github: Litee" },
  { "<leader>Ghp", group = "Github: Pull Request" },
  { "<leader>Ghr", group = "Github: Review" },
  { "<leader>Ght", group = "Github: Thread" },
  { "<leader>q", group = "Session/Quit" },
  { "<leader>s", group = "Search" },
  { "<leader>t", group = "Terminal" },
  { "<leader>u", group = "UI/Toggles" },
  { "<leader>v", group = "Visits" },
  { "<leader>w", group = "Window" },
})

-- Make which-key available globally for plugin configs to use
_G.WhichKey = wk
