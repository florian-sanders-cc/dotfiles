return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "dcampos/cmp-emmet-vim",
    "mattn/emmet-vim",
    "hrsh7th/cmp-emoji",
  },
  opts = function(_, opts)
    table.insert(opts.sources, { name = "emmet_vim" })
    table.insert(opts.sources, { name = "emoji" })
  end,
}
