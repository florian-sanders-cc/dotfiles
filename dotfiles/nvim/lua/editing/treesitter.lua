local function get_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  -- Remove /*, */, and {{{ with optional digits
  local sub = line:gsub("/%*", ""):gsub("%*/", ""):gsub("{{{%d*", "")
  return vim.v.folddashes .. sub
end

require("nvim-treesitter.configs").setup({
  -- Use only Nix-provided parsers, disable installation
  ensure_installed = {},
  auto_install = false,

  highlight = {
    enable = true,
    -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
    --  If you are experiencing weird indenting issues, add the language to
    --  the list of additional_vim_regex_highlighting and disabled languages for indent.
    additional_vim_regex_highlighting = false,
  },

  indent = { enable = true },

  -- Enable treesitter-based folding
  fold = {
    enable = true,
  },

  -- Incremental selection based on treesitter
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<M-o>", -- Start selection with Alt+O
      node_incremental = "<M-o>", -- Expand with Alt+O
      node_decremental = "<M-i>", -- Shrink with Alt+I
      scope_incremental = "<M-space>", -- Expand scope with Alt+N
    },
  },
})

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local has_parser = require("nvim-treesitter.parsers").has_parser(ft)
    if has_parser then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

vim.opt.foldcolumn = "0"
vim.opt.foldtext = get_fold_text()
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
