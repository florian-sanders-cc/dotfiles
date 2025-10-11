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
