return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "dcampos/cmp-emmet-vim",
    "mattn/emmet-vim",
  },
  opts = function(_, opts)
    table.insert(opts.sources, {
      name = "emmet_vim",
    })
  end,
}
