require("markdown").setup({
  mappings = {
    inline_surround_toggle = "<leader>mgs",       -- (string|boolean) toggle inline style
    inline_surround_toggle_line = "<leader>mgss", -- (string|boolean) line-wise toggle inline style
    inline_surround_delete = "<leader>mds",       -- (string|boolean) delete emphasis surrounding cursor
    inline_surround_change = "<leader>mcs",       -- (string|boolean) change emphasis surrounding cursor
    link_add = "<leader>mgl",                     -- (string|boolean) add link
    link_follow = "<leader>mgx",                  -- (string|boolean) follow link
    go_curr_heading = "<leader>m]c",              -- (string|boolean) set cursor to current section heading
    go_parent_heading = "<leader>m]p",            -- (string|boolean) set cursor to parent section heading
    go_next_heading = "<leader>m]]",              -- (string|boolean) set cursor to next section heading
    go_prev_heading = "<leader>m[[",              -- (string|boolean) set cursor to previous section heading
  },
})
