-- -- ┌─────────────────────────┐
-- -- │ Core Configuration      │
-- -- └─────────────────────────┘

require("core.mini-extra") -- Load before other mini modules that might use it
require("core.options") -- Includes mini.misc setup, autocmds, and keymaps
require("core.colorscheme")
require("core.persistence")

-- -- ┌─────────────────────────┐
-- -- │ Snacks Setup            │
-- -- └─────────────────────────┘

require("snacks").setup(
  vim.tbl_deep_extend(
    "force",
    require("navigation.snacks-picker"),
    require("navigation.snacks-explorer"),
    require("ui.snacks-bufdelete"),
    require("ui.snacks-toggle"),
    require("ui.snacks-zen"),
    require("ui.snacks-notifier"),
    require("ui.snacks-bigfile"),
    require("ui.snacks-quickfile"),
    require("ui.snacks-words"),
    require("ui.snacks-input")
  )
)

-- -- ┌─────────────────────────┐
-- -- │ Navigation Plugins      │
-- -- └─────────────────────────┘

require("navigation.mini-jump")
require("navigation.flash")
require("navigation.mini-files")
require("navigation.yazi")
require("navigation.mini-visits")

-- -- ┌─────────────────────────┐
-- -- │ UI Plugins              │
-- -- └─────────────────────────┘

require("ui.which-key") -- Load first so plugins can register keymaps
require("ui.statusline")
require("ui.mini-starter")
require("ui.mini-hipatterns")
require("ui.mini-icons")
require("ui.mini-indentscope")
require("ui.noice")

-- -- ┌─────────────────────────┐
-- -- │ Editing Plugins         │
-- -- └─────────────────────────┘

require("editing.mini-basics")
require("editing.guess-indent")
require("editing.mini-ai")
require("editing.mini-align")
require("editing.mini-bracketed")
require("editing.mini-pairs")
require("editing.mini-surround")
require("editing.mini-splitjoin")
require("editing.mini-comment")
require("editing.treesitter")
require("editing.multicursor")
require("editing.quicker")

-- -- Completion and snippets (load after treesitter for better integration)
require("editing.blink")
require("editing.mini-snippets")

-- -- Formatting (load after LSP setup for lsp_fallback)
require("editing.conform")

-- -- Text manipulation and markdown
require("editing.markdown")

-- -- ┌─────────────────────────┐
-- -- │ Git Integration         │
-- -- └─────────────────────────┘

require("git.mini-diff")
require("git.gitsigns")
require("git.neogit")
require("git.diffview")
require("git.gh")

-- -- ┌─────────────────────────┐
-- -- │ LSP Configuration       │
-- -- └─────────────────────────┘

require("lsp.lsp")

-- -- ┌─────────────────────────┐
-- -- │ Terminal                │
-- -- └─────────────────────────┘

require("terminal.config")

-- -- ┌─────────────────────────┐
-- -- │ AI                      │
-- -- └─────────────────────────┘

require("ai.claude")
require("ai.codecompanion")
require("ai.copilot")

-- -- ┌─────────────────────────┐
-- -- │ Final Overrides         │
-- -- └─────────────────────────┘

-- Ensure fillchars are set correctly after all plugins load
vim.schedule(function()
  vim.opt.fillchars:append({ fold = "･", diff = "" })
end)
