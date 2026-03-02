-- ┌─────────────────┐
-- │ hunk.nvim       │
-- └─────────────────┘
--
-- Diff editor for jj (and git). Used as jj's diff-editor via:
--   ui.diff-editor = ["nvim" "-c" "DiffEditor $left $right $output"]

require("hunk").setup({
  keys = {
    global = {
      quit = { "q" },
      accept = { "<leader><CR>" },
      focus_tree = { "<leader>e" },
    },
    diff = {
      toggle_hunk = { "A" },
      toggle_line = { "a" },
      toggle_line_pair = { "s" },
      prev_hunk = { "[h" },
      next_hunk = { "]h" },
      toggle_focus = { "<Tab>" },
    },
  },
  ui = {
    layout = "vertical",
    tree = {
      mode = "nested",
      width = 35,
    },
  },
})
