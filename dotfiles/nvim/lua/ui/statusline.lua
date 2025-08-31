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

require("mini.files").setup({
  options = {
    -- Whether to use for editing directories
    use_as_default_explorer = false,
  },
})

-- Configure Lualine (Status line)
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "auto",
    section_separators = { left = "", right = "" },
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

-- Configure Which-key (Key binding help)
require("which-key").setup()

require("nvim-web-devicons").setup({})
require("todo-comments").setup({})

-- UI keymaps and which-key configuration are now consolidated in plugin/keymaps.lua

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
