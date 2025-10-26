-- ┌──────────────────────────┐
-- │ Mini Hipatterns          │
-- └──────────────────────────┘
--
-- Highlight patterns in text like TODO/NOTE or color hex codes.

vim.schedule(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      -- Highlight a fixed set of common words
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

      -- Highlight hex color string (#aabbcc) with that color as background
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Usage: `:Pick hipatterns` to pick among all highlighted patterns

-- See `:h MiniHipatterns-examples` for common setups
