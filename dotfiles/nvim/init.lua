-- -- ┌─────────────────────────┐
-- -- │ Core Configuration      │
-- -- └─────────────────────────┘

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
    require("ui.snacks-notifier"),
    require("ui.snacks-bigfile"),
    require("ui.snacks-input")
  )
)

-- -- ┌─────────────────────────┐
-- -- │ Navigation Plugins      │
-- -- └─────────────────────────┘

require("navigation.flash")
require("navigation.yazi")

-- -- ┌─────────────────────────┐
-- -- │ UI Plugins              │
-- -- └─────────────────────────┘

require("ui.render-markdown")
require("ui.which-key") -- Load first so plugins can register keymaps
require("ui.statusline")
require("ui.mini-indentscope")
require("ui.ui2")
require("ui.icons")
require("ui.todo-comments")

-- -- ┌─────────────────────────┐
-- -- │ Editing Plugins         │
-- -- └─────────────────────────┘

require("editing.mini-align")
require("editing.mini-pairs")
require("editing.mini-surround")
require("editing.treesitter")
require("editing.multicursor")
require("editing.quicker")

-- -- Completion and snippets (load after treesitter for better integration)
require("editing.blink")

-- -- Formatting (load after LSP setup for lsp_fallback)
require("editing.conform")

-- -- Text manipulation and markdown
require("editing.markdown")

-- -- ┌─────────────────────────┐
-- -- │ Git Integration         │
-- -- └─────────────────────────┘

require("git.codediff")
require("git.hunk")
require("git.jj")
require("git.mini-diff")

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

require("ai.init")

-- -- ┌─────────────────────────┐
-- -- │ Final Overrides         │
-- -- └─────────────────────────┘

-- Ensure fillchars are set correctly after all plugins load
vim.schedule(function()
  vim.opt.fillchars:append({ fold = "･", diff = "" })
end)
