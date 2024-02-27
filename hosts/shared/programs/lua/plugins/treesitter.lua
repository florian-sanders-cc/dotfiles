return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "luckasRanarison/tree-sitter-hyprlang" },
  opts = function(_, opts)
    -- not sure jsdoc is working, TODO: will have to check later
    vim.list_extend(opts.ensure_installed, {
      "html",
      "css",
      "jsdoc",
      "markdown",
      "markdown_inline",
      "hyprlang",
      "nix",
    })
  end,
}
