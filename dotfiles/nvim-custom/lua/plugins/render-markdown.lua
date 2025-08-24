return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  event = "BufEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  opts = {
    win_options = {
      conceallevel = {
        default = 0,
        rendered = 0,
      },
    },
  },
}

