require("blink.cmp").setup({
  fuzzy = { implementation = "rust" },
  signature = { enabled = true },
  keymap = {
    preset = "enter",
    ["<C-k>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-b>"] = { "scroll_documentation_down", "fallback" },
    ["<C-f>"] = { "scroll_documentation_up", "fallback" },
    ["<C-e>"] = { "hide" },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "normal",
  },

  completion = {

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = {
        border = "solid",
      },
    },
    menu = {
      border = "solid",
      draw = {
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind_icon", "kind" },
        },
      },
    },
  },

  cmdline = {
    keymap = {
      preset = "inherit",
      ["<CR>"] = { "accept_and_enter", "fallback" },
    },
  },

  sources = {
    default = { "lsp", "buffer", "snippets", "path" },
  },
})
