local function get_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  -- Remove /*, */, and {{{ with optional digits
  local sub = line:gsub("/%*", ""):gsub("%*/", ""):gsub("{{{%d*", "")
  return vim.v.folddashes .. sub
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- Only enable treesitter if a parser exists for this filetype
    local ok = pcall(vim.treesitter.get_parser, 0)
    if not ok then
      return
    end
    -- Enable treesitter highlighting (replaces old highlight module)
    vim.treesitter.start()
    -- Enable treesitter folding
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldmethod = "expr"
  end,
})

vim.opt.foldcolumn = "0"
vim.opt.foldtext = get_fold_text()
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
