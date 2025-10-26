-- ┌──────────────────────┐
-- │ Colorscheme Setup    │
-- └──────────────────────┘
--
-- Set the colorscheme for Neovim

require("nordic").setup({
  -- Override highlight groups for hover/active items
  on_highlight = function(highlights, palette)
    -- Use lighter gray for better visibility
    local hover_bg = palette.gray1 -- More prominent hover background

    -- Cursor and selection
    highlights.CursorLine = { bg = hover_bg }

    -- Popup menu (completion, command-line, etc.)
    highlights.PmenuSel = { bg = hover_bg }

    highlights.TelescopeSelectionCaret = { bg = hover_bg }

    highlights.Visual = { bg = hover_bg }

    highlights.Folded = { fg = palette.gray3 }

    highlights.FoldColumn = { fg = "#6e738d", bg = "NONE" }
  end,
})

-- Load colorscheme
vim.cmd.colorscheme("nordic")
