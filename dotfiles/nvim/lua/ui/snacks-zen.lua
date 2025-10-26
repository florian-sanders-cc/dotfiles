-- ┌──────────────────────┐
-- │ Snacks Zen Mode      │
-- └──────────────────────┘
--
-- Zen mode for distraction-free editing

-- Defer keymap setup until after Snacks is fully initialized
vim.schedule(function()
  local Snacks = require("snacks")

  -- Zen mode toggle
  Snacks.toggle.zen():map("<leader>uz")
  Snacks.toggle.dim():map("<leader>uD")
end)

-- Config export
return {
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
