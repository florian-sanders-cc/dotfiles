-- ┌─────────────────┐
-- │ Mini AI         │
-- └─────────────────┘
--
-- Extend and create a/i textobjects with "next" and "last" variants.
-- Examples: ci), di(, yaq, vif, cina, valaala

vim.schedule(function()
  local ai = require('mini.ai')
  ai.setup({
    -- Custom textobjects
    custom_textobjects = {
      -- Make `aB` / `iB` act on around/inside whole *b*uffer
      B = MiniExtra.gen_ai_spec.buffer(),
      -- Make `aF`/`iF` mean around/inside function definition (requires tree-sitter)
      F = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    },

    -- Always try to search only covering textobject and explicitly ask to search
    -- for next (`an`/`in`) or last (`al`/`il`).
    search_method = 'cover',
  })
end)

-- See `:h MiniAi-builtin-textobjects` for list of supported textobjects
-- See `:h MiniAi-textobject-specification` for custom textobject examples
