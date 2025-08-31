-- =====================================================
-- FUZZY FINDER CONFIGURATION (Snacks Picker)
-- =====================================================

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
    },
  },
}