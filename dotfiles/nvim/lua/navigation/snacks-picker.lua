-- ┌──────────────────────┐
-- │ Snacks Picker        │
-- └──────────────────────┘
--
-- Fuzzy finder and picker interface for files, buffers, grep, and more.

-- Keymaps
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set({ "n", "v" }, "<Leader>" .. suffix, rhs, { desc = desc })
end

-- Top-level quick access
nmap_leader("ff", function()
  require("snacks").picker.smart()
end, "Smart Find Files")

nmap_leader(",", function()
  require("snacks").picker.buffers()
end, "Buffers")

nmap_leader("/", function()
  require("snacks").picker.grep()
end, "Grep")

nmap_leader(":", function()
  require("snacks").picker.command_history()
end, "Command History")

nmap_leader("n", function()
  require("snacks").picker.notifications()
end, "Notification History")

-- File finding (<leader>f)
nmap_leader("fb", function()
  require("snacks").picker.buffers()
end, "Buffers")

nmap_leader("fc", function()
  require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
end, "Find Config File")

nmap_leader("<space>", function()
  require("snacks").picker.files()
end, "Find Files")

nmap_leader("fg", function()
  require("snacks").picker.git_files()
end, "Find Git Files")

nmap_leader("fp", function()
  require("snacks").picker.projects()
end, "Projects")

nmap_leader("fr", function()
  require("snacks").picker.recent()
end, "Recent")

-- Search operations (<leader>s)
nmap_leader("sb", function()
  require("snacks").picker.lines()
end, "Buffer Lines")

nmap_leader("sB", function()
  require("snacks").picker.grep_buffers()
end, "Grep Open Buffers")

nmap_leader("sg", function()
  require("snacks").picker.grep()
end, "Grep")

nmap_leader("sw", function()
  require("snacks").picker.grep_word()
end, "Visual selection or word")

nmap_leader('s"', function()
  require("snacks").picker.registers()
end, "Registers")

nmap_leader("s/", function()
  require("snacks").picker.search_history()
end, "Search History")

nmap_leader("sa", function()
  require("snacks").picker.autocmds()
end, "Autocmds")

nmap_leader("sc", function()
  require("snacks").picker.command_history()
end, "Command History")

nmap_leader("sC", function()
  require("snacks").picker.commands()
end, "Commands")

nmap_leader("sd", function()
  require("snacks").picker.diagnostics()
end, "Diagnostics")

nmap_leader("sD", function()
  require("snacks").picker.diagnostics_buffer()
end, "Buffer Diagnostics")

nmap_leader("sh", function()
  require("snacks").picker.help()
end, "Help Pages")

nmap_leader("sH", function()
  require("snacks").picker.highlights()
end, "Highlights")

nmap_leader("si", function()
  require("snacks").picker.icons()
end, "Icons")

nmap_leader("sj", function()
  require("snacks").picker.jumps()
end, "Jumps")

nmap_leader("sk", function()
  require("snacks").picker.keymaps()
end, "Keymaps")

nmap_leader("sl", function()
  require("snacks").picker.loclist()
end, "Location List")

nmap_leader("sm", function()
  require("snacks").picker.marks()
end, "Marks")

nmap_leader("sM", function()
  require("snacks").picker.man()
end, "Man Pages")

nmap_leader("sp", function()
  require("snacks").picker.lazy()
end, "Search for Plugin Spec")

nmap_leader("sq", function()
  require("snacks").picker.qflist()
end, "Quickfix List")

nmap_leader("sR", function()
  require("snacks").picker.resume()
end, "Resume")

nmap_leader("ss", function()
  require("snacks").picker.lsp_symbols({
    sort = { "#text" },
  })
end, "LSP Symbols")

nmap_leader("sS", function()
  require("snacks").picker.lsp_workspace_symbols()
end, "LSP Workspace Symbols")

nmap_leader("su", function()
  require("snacks").picker.undo()
end, "Undo History")

nmap_leader("uC", function()
  require("snacks").picker.colorschemes()
end, "Colorschemes")

-- Config export
return {
  picker = {
    enabled = true,
    win = {
      input = {
        keys = {
          ["<c-h>"] = { "toggle_hidden", mode = { "i", "n" } },
          ["<c-i>"] = { "toggle_ignored", mode = { "i", "n" } },
          ["<c-g>"] = { "toggle_follow", mode = { "i", "n" } },
          ["<c-f>"] = { "toggle_filter", mode = { "i", "n" } },
          ["<c-q>"] = { "qflist", mode = { "n", "i" } },
        },
      },
      -- list = {
      --   wo = {
      --     -- Fix for invisible text in LSP symbols and other pickers
      --     -- The issue is that conceal might hide important text
      --     conceallevel = 0, -- Disable concealment to ensure text is visible
      --     cursorline = true, -- Enable cursor line for visible hover highlighting
      --   },
      --   bo = {},
      --   b = {},
      -- },
    },
  },
}
