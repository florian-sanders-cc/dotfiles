-- =====================================================
-- SNACKS UI Configuration (Toggles, Notifications, etc.)
-- =====================================================

local M = {}

M.config = {
  -- Core UI features
  bigfile = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },

  -- Input dialog
  input = {
    enabled = true,
  },

  -- Indent guides
  indent = {
    indent = {
      enabled = true,
      char = "‧", -- dotted line character
      only_current = true,
    },
    chunk = {
      enabled = true, -- enable chunk rendering with curved borders
      only_current = true,
      char = {
        corner_top = "╭", -- curved top corner
        corner_bottom = "╰", -- curved bottom corner
        horizontal = "", -- horizontal line
        vertical = "│", -- vertical line
        arrow = "", -- arrow for chunk indication
      },
    },
    scope = { enabled = true },
  },

  -- Toggles
  toggle = {
    enabled = true,
  },

  -- Zen mode
  zen = {
    enabled = true,
    toggles = {
      dim = true,
      git_signs = false,
      mini_diff_signs = false,
      diagnostics = false,
      inlay_hints = false,
    },
    show = {
      statusline = false,
      tabline = false,
    },
    win = {
      fixbuf = false,
    },
  },
}

M.keymaps = {
  -- Notifications
  {
    { "n", "v" },
    "<leader>sn",
    function()
      require("snacks").notifier.show_history()
    end,
    { desc = "Show notification history" },
  },
  {
    { "n", "v" },
    "<leader>un",
    function()
      require("snacks").notifier.hide()
    end,
    { desc = "Hide notifications" },
  },

  -- Toggles (<leader>u)
  {
    "n",
    "<leader>us",
    function()
      require("snacks").toggle.option("spell")
    end,
    { desc = "Toggle Spelling" },
  },
  {
    "n",
    "<leader>uw",
    function()
      require("snacks").toggle.option("wrap")
    end,
    { desc = "Toggle Wrap" },
  },
  {
    "n",
    "<leader>uL",
    function()
      require("snacks").toggle.option("relativenumber")
    end,
    { desc = "Toggle Relative Number" },
  },
  {
    "n",
    "<leader>ud",
    function()
      require("snacks").toggle.diagnostics()
    end,
    { desc = "Toggle Diagnostics" },
  },
  {
    "n",
    "<leader>ul",
    function()
      require("snacks").toggle.line_number()
    end,
    { desc = "Toggle Line Numbers" },
  },
  {
    "n",
    "<leader>uc",
    function()
      require("snacks").toggle.option("conceallevel", {
        off = 0,
        on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
      })
    end,
    { desc = "Toggle Conceal Level" },
  },
  {
    "n",
    "<leader>uT",
    function()
      require("snacks").toggle.treesitter()
    end,
    { desc = "Toggle Treesitter" },
  },
  {
    "n",
    "<leader>ub",
    function()
      require("snacks").toggle.option("background", { off = "light", on = "dark" })
    end,
    { desc = "Toggle Background" },
  },
  {
    "n",
    "<leader>uh",
    function()
      require("snacks").toggle.inlay_hints()
    end,
    { desc = "Toggle Inlay Hints" },
  },
  {
    "n",
    "<leader>ug",
    function()
      require("snacks").toggle.indent()
    end,
    { desc = "Toggle Indent Guides" },
  },
  {
    "n",
    "<leader>uz",
    function()
      require("snacks").toggle.zen()
    end,
    { desc = "Toggle Zen Mode" },
  },
  {
    "n",
    "<leader>uD",
    function()
      require("snacks").toggle.dim()
    end,
    { desc = "Toggle Dim Mode" },
  },
}

return M
