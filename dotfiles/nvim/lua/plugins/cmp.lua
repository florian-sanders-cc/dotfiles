return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.completion = {
      completeopt = "menu,menuone,noinsert",
      documentation = {
        virtual_text = {
          enabled = false,
        },
      },
    }
  end,
}
