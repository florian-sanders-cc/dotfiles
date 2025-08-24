return {
  'windwp/nvim-ts-autotag',
  event = { 'BufReadPost', 'BufNewFile' },
  ft = { 'html', 'xml', 'tsx', 'jsx', 'vue', 'svelte', 'js', 'ts' },
  opts = function()
    require('nvim-ts-autotag').setup {
      opts = {
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = true, -- Auto close on trailing </
      },
    }
  end,
}
