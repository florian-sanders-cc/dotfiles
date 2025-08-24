-- =====================================================
-- SNACKS PICKER (Fuzzy Finder) Configuration
-- =====================================================

local M = {}

M.config = {
  picker = {
    enabled = true,
    win = {
      input = {
        keys = {
          ["<c-h>"] = { "toggle_hidden", mode = { "i", "n" } },
          ["<c-i>"] = { "toggle_ignored", mode = { "i", "n" } },
          ["<c-g>"] = { "toggle_follow", mode = { "i", "n" } },
          ["<c-f>"] = { "toggle_filter", mode = { "i", "n" } },
        },
      },
    },
  }
}

M.keymaps = {
  -- Top-level quick access
  {
    { "n",                      "v" },
    "<leader><space>",
    function() require("snacks").picker.smart() end,
    { desc = "Smart Find Files" }
  },
  {
    { "n",             "v" },
    "<leader>,",
    function() require("snacks").picker.buffers() end,
    { desc = "Buffers" }
  },
  {
    { "n",          "v" },
    "<leader>/",
    function() require("snacks").picker.grep() end,
    { desc = "Grep" }
  },
  {
    { "n",                     "v" },
    "<leader>:",
    function() require("snacks").picker.command_history() end,
    { desc = "Command History" }
  },
  {
    { "n",                          "v" },
    "<leader>n",
    function() require("snacks").picker.notifications() end,
    { desc = "Notification History" }
  },

  -- File finding (<leader>f)
  {
    { "n",             "v" },
    "<leader>fb",
    function() require("snacks").picker.buffers() end,
    { desc = "Buffers" }
  },
  {
    { "n",                      "v" },
    "<leader>fc",
    function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end,
    { desc = "Find Config File" }
  },
  {
    { "n",                "v" },
    "<leader>ff",
    function() require("snacks").picker.files() end,
    { desc = "Find Files" }
  },
  {
    { "n",                    "v" },
    "<leader>fg",
    function() require("snacks").picker.git_files() end,
    { desc = "Find Git Files" }
  },
  {
    { "n",              "v" },
    "<leader>fp",
    function() require("snacks").picker.projects() end,
    { desc = "Projects" }
  },
  {
    { "n",            "v" },
    "<leader>fr",
    function() require("snacks").picker.recent() end,
    { desc = "Recent" }
  },

  -- Search operations (<leader>s)
  {
    { "n",                  "v" },
    "<leader>sb",
    function() require("snacks").picker.lines() end,
    { desc = "Buffer Lines" }
  },
  {
    { "n",                       "v" },
    "<leader>sB",
    function() require("snacks").picker.grep_buffers() end,
    { desc = "Grep Open Buffers" }
  },
  {
    { "n",          "v" },
    "<leader>sg",
    function() require("snacks").picker.grep() end,
    { desc = "Grep" }
  },
  {
    { "n",                              "v" },
    "<leader>sw",
    function() require("snacks").picker.grep_word() end,
    { desc = "Visual selection or word" }
  },
  {
    { "n",               "v" },
    '<leader>s"',
    function() require("snacks").picker.registers() end,
    { desc = "Registers" }
  },
  {
    { "n",                    "v" },
    "<leader>s/",
    function() require("snacks").picker.search_history() end,
    { desc = "Search History" }
  },
  {
    { "n",              "v" },
    "<leader>sa",
    function() require("snacks").picker.autocmds() end,
    { desc = "Autocmds" }
  },
  {
    { "n",                     "v" },
    "<leader>sc",
    function() require("snacks").picker.command_history() end,
    { desc = "Command History" }
  },
  {
    { "n",              "v" },
    "<leader>sC",
    function() require("snacks").picker.commands() end,
    { desc = "Commands" }
  },
  {
    { "n",                 "v" },
    "<leader>sd",
    function() require("snacks").picker.diagnostics() end,
    { desc = "Diagnostics" }
  },
  {
    { "n",                        "v" },
    "<leader>sD",
    function() require("snacks").picker.diagnostics_buffer() end,
    { desc = "Buffer Diagnostics" }
  },
  {
    { "n",                "v" },
    "<leader>sh",
    function() require("snacks").picker.help() end,
    { desc = "Help Pages" }
  },
  {
    { "n",                "v" },
    "<leader>sH",
    function() require("snacks").picker.highlights() end,
    { desc = "Highlights" }
  },
  {
    { "n",           "v" },
    "<leader>si",
    function() require("snacks").picker.icons() end,
    { desc = "Icons" }
  },
  {
    { "n",           "v" },
    "<leader>sj",
    function() require("snacks").picker.jumps() end,
    { desc = "Jumps" }
  },
  {
    { "n",             "v" },
    "<leader>sk",
    function() require("snacks").picker.keymaps() end,
    { desc = "Keymaps" }
  },
  {
    { "n",                   "v" },
    "<leader>sl",
    function() require("snacks").picker.loclist() end,
    { desc = "Location List" }
  },
  {
    { "n",           "v" },
    "<leader>sm",
    function() require("snacks").picker.marks() end,
    { desc = "Marks" }
  },
  {
    { "n",               "v" },
    "<leader>sM",
    function() require("snacks").picker.man() end,
    { desc = "Man Pages" }
  },
  {
    { "n",                            "v" },
    "<leader>sp",
    function() require("snacks").picker.lazy() end,
    { desc = "Search for Plugin Spec" }
  },
  {
    { "n",                   "v" },
    "<leader>sq",
    function() require("snacks").picker.qflist() end,
    { desc = "Quickfix List" }
  },
  {
    { "n",            "v" },
    "<leader>sR",
    function() require("snacks").picker.resume() end,
    { desc = "Resume" }
  },
  {
    { "n",                 "v" },
    "<leader>ss",
    function() require("snacks").picker.lsp_symbols() end,
    { desc = "LSP Symbols" }
  },
  {
    { "n",                           "v" },
    "<leader>sS",
    function() require("snacks").picker.lsp_workspace_symbols() end,
    { desc = "LSP Workspace Symbols" }
  },
  {
    { "n",                  "v" },
    "<leader>su",
    function() require("snacks").picker.undo() end,
    { desc = "Undo History" }
  },
  {
    { "n",                  "v" },
    "<leader>uC",
    function() require("snacks").picker.colorschemes() end,
    { desc = "Colorschemes" }
  },

  -- LSP Navigation (Global Keys)
  {
    { "n",                     "v" },
    "gd",
    function() require("snacks").picker.lsp_definitions() end,
    { desc = "Goto Definition" }
  },
  {
    { "n",                      "v" },
    "gD",
    function() require("snacks").picker.lsp_declarations() end,
    { desc = "Goto Declaration" }
  },
  {
    { "n",           "v" },
    "gr",
    function() require("snacks").picker.lsp_references() end,
    { nowait = true, desc = "References" }
  },
  {
    { "n",                         "v" },
    "gI",
    function() require("snacks").picker.lsp_implementations() end,
    { desc = "Goto Implementation" }
  },
  {
    { "n",                            "v" },
    "gy",
    function() require("snacks").picker.lsp_type_definitions() end,
    { desc = "Goto T[y]pe Definition" }
  },
}

return M
