require("mini.align").setup({})
require("multicursors").setup({
  hint_config = {
    float_opts = {
      border = "rounded",
    },
    position = "bottom-right",
  },
  generate_hints = {
    normal = true,
    insert = true,
    extend = true,
    config = {
      column_count = 1,
    },
  },
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

vim.keymap.set("c", "<c-s>", function()
  require("flash").toggle()
end, { desc = "Toggle Flash Search" })

vim.keymap.set(
  { "v", "n" },
  "<Leader>m",
  "<cmd>MCstart<cr>",
  { desc = "Create a selection for selected text or word under the cursor" }
)

vim.keymap.set({ "n", "v" }, "<leader>sr", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and Replace" })

vim.keymap.set({ "n", "o", "x" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "o", "x" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })
