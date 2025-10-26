-- ┌──────────────────────┐
-- │ Snacks Toggle        │
-- └──────────────────────┘
--
-- Toggle utilities for various editor options

-- Defer keymap setup until after Snacks is fully initialized
vim.schedule(function()
  local Snacks = require("snacks")

  -- Toggle keymaps (<leader>u)
  Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
  Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
  Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
  Snacks.toggle.diagnostics():map("<leader>ud")
  Snacks.toggle.line_number():map("<leader>ul")
  Snacks.toggle
      .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
      :map("<leader>uc")
  Snacks.toggle.treesitter():map("<leader>uT")
  Snacks.toggle.inlay_hints():map("<leader>uh")

  -- Custom formatting toggle
  Snacks.toggle({
    name = "Auto Formatting",
    get = function()
      return not vim.g.disable_autoformat and not vim.b.disable_autoformat
    end,
    set = function(state)
      if state then
        vim.g.disable_autoformat = false
        vim.b.disable_autoformat = false
      else
        vim.g.disable_autoformat = true
      end
    end,
  }):map("<leader>uf")
end)

-- Config export
return {
  toggle = {
    enabled = true,
  },
}
