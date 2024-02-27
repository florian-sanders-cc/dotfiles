return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "dawsers/telescope-file-history.nvim",
      config = function()
        require("file_history").setup({
          backup_dir = "/home/flo/.file-history-git",
          git_cmd = "git",
        })
        require("telescope").load_extension("file_history")
      end,
    },
  },
}
