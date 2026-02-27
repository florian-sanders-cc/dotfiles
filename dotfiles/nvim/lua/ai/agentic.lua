require("agentic").setup({
  provider = "opencode-acp",
})

vim.keymap.set({ "n", "v", "i" }, "<leader>at", function()
  require("agentic").toggle()
end, { desc = "AI: Agentic Toggle" })

vim.keymap.set({ "n", "v" }, "<leader>ao", function()
  require("agentic").add_selection_or_file_to_context()
end, { desc = "AI: Agentic Add to Context" })
