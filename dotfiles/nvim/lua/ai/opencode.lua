-- ┌──────────────────────────┐
-- │ OpenCode.nvim            │
-- └──────────────────────────┘
--
-- Integrate the opencode AI assistant with Neovim.
-- Provides editor-aware research, reviews, and requests.
--
-- Available contexts:
--   @this       - Operator range or visual selection if any, else cursor position
--   @buffer     - Current buffer
--   @buffers    - Open buffers
--   @visible    - Visible text
--   @diagnostics - Current buffer diagnostics
--   @quickfix   - Quickfix list
--   @diff       - Git diff
--   @marks      - Global marks
--
-- Available prompts: diagnostics, diff, document, explain, fix, implement, optimize, review, test

---@type opencode.Opts
vim.g.opencode_opts = {
  provider = {
    enabled = "snacks",
    snacks = {},
  },
  events = {
    reload = true, -- Auto-reload buffers edited by opencode
  },
}

-- Required for opts.events.reload
vim.o.autoread = true

-- Keymaps using <leader>a prefix (consistent with existing AI keymaps)
vim.keymap.set({ "n", "x" }, "<leader>ao", function()
  require("opencode").ask()
end, { desc = "AI: OpenCode Ask" })

vim.keymap.set({ "n", "x" }, "<leader>aO", function()
  require("opencode").select()
end, { desc = "AI: OpenCode Select Action" })

vim.keymap.set({ "n", "t" }, "<leader>at", function()
  require("opencode").toggle()
end, { desc = "AI: OpenCode Toggle" })

-- Operator for adding ranges to opencode (go = operator, goo = current line)
vim.keymap.set({ "n", "x" }, "go", function()
  return require("opencode").operator("@this ")
end, { desc = "Add range to OpenCode", expr = true })

vim.keymap.set("n", "goo", function()
  return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line to OpenCode", expr = true })

-- Scroll commands (useful when opencode terminal is not focused)
vim.keymap.set("n", "<leader>a[", function()
  require("opencode").command("session.half.page.up")
end, { desc = "AI: OpenCode Scroll Up" })

vim.keymap.set("n", "<leader>a]", function()
  require("opencode").command("session.half.page.down")
end, { desc = "AI: OpenCode Scroll Down" })
