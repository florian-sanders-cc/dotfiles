require("persistence").setup({
  dir = vim.fn.stdpath("state") .. "/sessions/",
  need = 1,
  branch = true,
})

-- Configure session options to exclude certain filetypes
vim.opt.sessionoptions:append("globals")
vim.opt.sessionoptions:remove("blank")

-- Session keymaps are now consolidated in plugin/keymaps.lua
