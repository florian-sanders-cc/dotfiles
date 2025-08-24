return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      indent = {
        enabled = true,
        char = '‧', -- dotted line character
        only_current = true,
      },
      chunk = {
        enabled = true, -- enable chunk rendering with curved borders
        only_current = true,
        char = {
          corner_top = '╭', -- curved top corner
          corner_bottom = '╰', -- curved bottom corner
          horizontal = '', -- horizontal line
          vertical = '│', -- vertical line
          arrow = '', -- arrow for chunk indication
        },
      },
      scope = { enabled = true },
    },
  },
}

