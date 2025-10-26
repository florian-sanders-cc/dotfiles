require("persistence").setup({
  dir = vim.fn.stdpath("state") .. "/sessions/",
  need = 1,
  branch = true,
})

-- Configure session options to exclude certain filetypes
vim.opt.sessionoptions:append("globals")
vim.opt.sessionoptions:remove("blank")

vim.keymap.set("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Load session for current directory" })

vim.keymap.set("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Select session to load" })

vim.keymap.set("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Load last session" })

vim.keymap.set("n", "<leader>qq", require("lib.session-quit").quit_with_session_save, {
  desc = "Save session and quit",
})
