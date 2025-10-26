-- ┌─────────────────────────┐
-- │ Guess Indent            │
-- └─────────────────────────┘
--
-- Blazing fast automatic indentation detection for Neovim.
-- Analyzes buffer content and automatically sets tabstop, shiftwidth, and expandtab.

require("guess-indent").setup({
  -- Automatically detect indentation on buffer read
  auto_cmd = true,

  -- Override editorconfig with detected indentation
  override_editorconfig = false,

  -- List of filetypes to ignore (special buffers and UI elements)
  filetype_exclude = {
    "netrw",
    "tutor",
    "noice",
    "notify",
    "snacks_input",
    "snacks_picker_list",
    "snacks_picker_preview",
    "snacks_notifier",
    "snacks_terminal",
    "starter", -- mini.starter
    "gitcommit",
    "gitrebase",
  },

  -- List of buffer types to ignore
  buftype_exclude = {
    "help",
    "nofile",
    "terminal",
    "prompt",
  },
})
