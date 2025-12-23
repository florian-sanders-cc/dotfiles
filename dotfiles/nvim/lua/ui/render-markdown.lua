require("render-markdown").setup({})

vim.schedule(function()
  local Snacks = require("snacks")

  Snacks.toggle({
    name = "Render Markdown",
    get = function()
      return require("render-markdown").get()
    end,
    set = function(state)
      if state then
        require("render-markdown").enable()
      else
        require("render-markdown").disable()
      end
    end,
  }):map("<leader>um")
end)
