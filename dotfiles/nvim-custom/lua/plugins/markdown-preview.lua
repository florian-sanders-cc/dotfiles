return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && yarn install',
  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
  ft = { 'markdown' },
  keys = {
    {
      '<leader>up',
      '<cmd>MarkdownPreviewToggle<cr>',
      desc = 'Markdown Preview',
      ft = 'markdown',
    },
  },
}