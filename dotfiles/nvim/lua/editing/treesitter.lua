local function get_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  -- Remove /*, */, and {{{ with optional digits
  local sub = line:gsub("/%*", ""):gsub("%*/", ""):gsub("{{{%d*", "")
  return vim.v.folddashes .. sub
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    -- Only enable treesitter if a parser exists for this filetype
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if not lang then
      return
    end

    if not vim.treesitter.language.add(lang) then
      return
    end

    -- Enable treesitter highlighting (replaces old highlight module)
    vim.treesitter.start()
    -- Enable treesitter folding
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldmethod = "expr"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.opt.foldcolumn = "0"
vim.opt.foldtext = get_fold_text()
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- ┌─────────────────────────────────────────┐
-- │ Incremental Node Selection (Alt-i/Alt-o)│
-- └─────────────────────────────────────────┘

vim.keymap.set({ "n", "x", "o" }, "<A-o>", function()
  require("flash").treesitter({
    actions = {
      ["<A-o>"] = "next",
      ["<A-i>"] = "prev",
    },
  })
end, { desc = "Treesitter incremental selection" })
