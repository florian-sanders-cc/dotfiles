require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "copilot",
    },
    inline = {
      adapter = "copilot",
    },
    cmd = {
      adapter = "copilot",
    },
  },
  prompt_library = {
    ["Commit message"] = {
      strategy = "inline",
      description = "Generate a commit message based on the diff",
      prompts = {
        {
          role = "system",
          content = function()
            return string.format(
              [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:

```diff
%s
```
]],
              vim.fn.system("git diff --no-ext-diff --staged")
            )
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
  },
})

vim.keymap.set(
  { "n", "v" },
  "<leader>ai",
  ":CodeCompanion ",
  { desc = "AI: CodeCompanion Inline", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>ac",
  "<cmd>CodeCompanionChat<CR>",
  { desc = "AI: CodeCompanion Chat", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>am",
  "<cmd>CodeCompanionCmd<CR>",
  { desc = "AI: CodeCompanion Command", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>aa",
  "<cmd>CodeCompanionActions<CR>",
  { desc = "AI: CodeCompanion Actions", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>ag",
  ":CodeCompanion <CR>",
  { desc = "AI: CodeCompanion Resume", noremap = true, silent = true }
)
