-- =====================================================
-- UI MISCELLANEOUS CONFIGURATION (Snacks UI Components)
-- Toggles, Notifications, Zen mode, Indent guides
-- =====================================================

vim.cmd.colorscheme("nordic")

vim.opt.splitright = true -- Vertical splits to the right
vim.opt.splitbelow = true -- Horizontal splits below
vim.opt.signcolumn = "yes:1" -- Always show sign column

vim.opt.termguicolors = true -- Enable true colors

vim.opt.winborder = "shadow"

vim.opt.conceallevel = 0 -- Always show all text, no conceal

vim.opt.laststatus = 3 -- spread status line (but it's handle through lualine anyway)
vim.opt.cmdheight = 0 -- Hide command line when not used

vim.opt.cursorline = true -- Highlight current line
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.numberwidth = 2

vim.g.have_nerd_font = true

-- Whitespace display
vim.opt.list = false -- Show whitespace characters (LazyVim enables, native disables)
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Whitespace characters

-- Timing
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 300 -- Shorter timeout for which-key

vim.opt.showtabline = 0

if vim.fn.has("nvim-0.12") == 1 then
  require("vim._extui").enable({})
end

if vim.g.neovide then
  vim.o.linespace = 10
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_left = 10

  vim.g.neovide_cursor_trail_size = 0.1
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_cursor_vfx_mode = "pixiedust"

  vim.g.neovide_profiler = false
  vim.o.guifont = "JetBrainsMono NFP Light"
end

require("noice").setup({
  lsp = {
    progress = {
      enabled = false,
    },
    override = {
      -- override the default lsp markdown formatter with Noice
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      -- override the lsp markdown formatter with Noice
      ["vim.lsp.util.stylize_markdown"] = true,
    },
    hover = {
      enabled = true,
      silent = false, -- set to true to not show a message if hover is not available
      view = nil, -- when nil, use defaults from documentation
      ---@type NoiceViewOptions
      opts = {
        size = {
          width = "auto",
          height = "auto",
          max_height = 10,
          max_width = 120,
        },
        position = { row = 2, col = 1 },
        border = {
          style = "shadow",
          padding = { 1, 3 },
        },
      }, -- merged with defaults from documentation
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = true,
        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
        throttle = 50, -- Debounce lsp signature help request by 50ms
      },
      view = nil, -- when nil, use defaults from documentation
      ---@type NoiceViewOptions
      opts = {}, -- merged with defaults from documentation
    },
    message = {
      -- Messages shown by lsp servers
      enabled = true,
      view = "notify",
      opts = {},
    },
    -- defaults for hover and signature help
    documentation = {
      view = "hover",
      ---@type NoiceViewOptions
      opts = {
        lang = "markdown",
        replace = true,
        render = "plain",
        format = { "{message}" },
        win_options = { concealcursor = "n", conceallevel = 3 },
      },
    },
  },
})

return {
  -- Core UI features
  bigfile = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  words = { enabled = true },

  -- Input dialog
  input = {
    enabled = false, -- Disabled to avoid conflict with inc_rename
  },

  -- Indent guides
  indent = {
    indent = {
      enabled = true,
      char = "‧", -- dotted line character
      only_current = true,
    },
    chunk = {
      enabled = true, -- enable chunk rendering with curved borders
      only_current = true,
      char = {
        corner_top = "╭", -- curved top corner
        corner_bottom = "╰", -- curved bottom corner
        horizontal = "", -- horizontal line
        vertical = "│", -- vertical line
        arrow = "", -- arrow for chunk indication
      },
    },
    scope = { enabled = true },
  },

  -- Toggles
  toggle = {
    enabled = true,
  },

  -- Zen mode
  zen = {
    enabled = true,
    toggles = {
      dim = true,
      git_signs = false,
      mini_diff_signs = false,
      diagnostics = false,
      inlay_hints = false,
    },
    show = {
      statusline = false,
      tabline = false,
    },
    win = {
      fixbuf = false,
    },
  },
}
