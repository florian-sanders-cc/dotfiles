-- ┌──────────────────────┐
-- │ Snacks Input         │
-- └──────────────────────┘
--
-- Beautiful input prompts using nui-inspired styling

-- Config export
return {
  input = {
    enabled = true,
    icon = " ",
    icon_hl = "SnacksInputIcon",
    icon_pos = "left",
    prompt_pos = "title",
    expand = true,
    win = {
      relative = "cursor",
      row = -3,
      col = 0,
      position = "float",
      border = "rounded",
      title_pos = "center",
      height = 1,
      width = 60,
      backdrop = false,
      noautocmd = true,
      wo = {
        winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
        cursorline = false,
        winblend = 10, -- Slight transparency for modern look
      },
      bo = {
        filetype = "snacks_input",
        buftype = "prompt",
      },
      -- Buffer-local variables
      b = {
        completion = false, -- Disable blink completions in input
      },
      keys = {
        n_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "n", expr = true },
        i_esc = { "<esc>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
        i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = { "i", "n" }, expr = true },
        i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i", expr = true },
        i_ctrl_w = { "<c-w>", "<c-s-w>", mode = "i", expr = true },
        i_up = { "<up>", { "hist_up" }, mode = { "i", "n" } },
        i_down = { "<down>", { "hist_down" }, mode = { "i", "n" } },
        q = "cancel",
      },
    },
  },
}
