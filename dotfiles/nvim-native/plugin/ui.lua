-- =====================================================
-- UI ENHANCEMENTS CONFIGURATION
-- Lualine, Which-key, and other UI improvements
-- =====================================================
function isRecording()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end -- not recording
  return "q@" .. reg
end

-- Configure Lualine (Status line)
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "auto",
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = false,
    globalstatus = true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 16, -- ~60fps
      events = {
        "WinEnter",
        "BufEnter",
        "BufWritePost",
        "SessionLoadPost",
        "FileChangedShellPost",
        "VimResized",
        "Filetype",
        "CursorMoved",
        "CursorMovedI",
        "ModeChanged",
      },
    },
  },
  sections = {
    lualine_a = { "mode", { isRecording } },
    lualine_b = { "branch" },
    lualine_c = { "filename" },
    lualine_y = {
      {
        "lsp_status",
        icon = "", -- f013
        symbols = {
          -- Standard unicode symbols to cycle through for LSP progress:
          spinner = { "", "", "", "", "", "" },
          -- Standard unicode symbol for when LSP is done:
          done = "✓",
          -- Delimiter inserted between LSP names:
          separator = "  ",
        },
        -- List of LSP names to ignore (e.g., `null-ls`):
        ignore_lsp = {},
      },
    },
    lualine_x = { "encoding", { "filetype", icon_only = true } },
    lualine_z = { "location" },
  },
  inactive_sections = {},
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
})

vim.o.showtabline = 0

-- Configure Which-key (Key binding help)
require("which-key").setup()

require("nvim-web-devicons").setup({})
require("todo-comments").setup({})

vim.keymap.set("n", "<leader>xt", function()
  require("snacks").picker.todo_comments({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Todo Comments (Buffer)" })

vim.keymap.set("n", "<leader>xT", function()
  require("snacks").picker.todo_comments()
end, { desc = "Todo Comments (Workspace)" })

-- Document existing key chains to match our keymap organization
require("which-key").add({
  -- Main groups
  { "<leader>a", group = "[A]I/Claude Code" },
  { "<leader>a_", hidden = true },
  { "<leader>b", group = "[B]uffer" },
  { "<leader>b_", hidden = true },
  { "<leader>c", group = "[C]ode" },
  { "<leader>c_", hidden = true },
  { "<leader>f", group = "[F]ind" },
  { "<leader>f_", hidden = true },
  { "<leader>g", group = "[G]it" },
  { "<leader>g_", hidden = true },
  { "<leader>o", group = "[O]cto (GitHub)" },
  { "<leader>o_", hidden = true },
  { "<leader>q", group = "[Q]uit/Session" },
  { "<leader>q_", hidden = true },
  { "<leader>s", group = "[S]earch" },
  { "<leader>s_", hidden = true },
  { "<leader>u", group = "[U]I/Toggle" },
  { "<leader>u_", hidden = true },
  { "<leader>x", group = "Diagnostics/Trouble" },
  { "<leader>x_", hidden = true },

  -- Single key items
  { "<leader>D", desc = "Dashboard" },
  { "<leader>e", desc = "File Explorer" },
  { "<leader>n", desc = "Notifications" },

  -- Visual mode specific
  {
    mode = { "v" },
    { "<leader>h", group = "Git [H]unk" },
    { "<leader>h_", hidden = true },
  },
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 170 })
  end,
  group = highlight_group,
})

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

require("noice").setup({
  lsp = {
    progress = {
      enabled = false,
    },

    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = true, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },
})
