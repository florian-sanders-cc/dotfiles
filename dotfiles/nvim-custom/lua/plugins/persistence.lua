return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      need = 1,
      branch = true,
    },
    config = function(_, opts)
      require("persistence").setup(opts)

      -- Configure session options to exclude certain filetypes
      vim.opt.sessionoptions:append("globals")
      vim.opt.sessionoptions:remove("blank")

      -- Set up autocmds for plugin integration hooks
      local group = vim.api.nvim_create_augroup("PersistenceHooks", { clear = true })

      -- Pre-save hook: close file trees and disable plugins
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        group = group,
        callback = function()
          -- Close nvim-tree if open
          if package.loaded["nvim-tree"] then
            require("nvim-tree.api").tree.close()
          end

          -- Close neo-tree if open
          if package.loaded["neo-tree"] then
            vim.cmd("Neotree close")
          end

          -- Close snacks explorer if open
          if package.loaded["snacks"] then
            local snacks = require("snacks")
            if snacks.explorer then
              -- Close all explorer windows
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.bo[buf].filetype
                if ft == "snacks_explorer" then
                  vim.api.nvim_win_close(win, false)
                end
              end
            end

            -- Disable snacks indent before saving
            if snacks.indent then
              snacks.indent.disable()
            end
          end
        end,
      })

      -- Post-restore hook: re-enable and refresh plugins
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceLoadPost",
        group = group,
        callback = function()
          vim.schedule(function()
            -- Close any lingering explorer windows that might have been restored
            if package.loaded["snacks"] then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.bo[buf].filetype
                if ft == "snacks_explorer" then
                  vim.api.nvim_win_close(win, false)
                end
              end

              -- Re-enable snacks indent after restoring
              if require("snacks").indent then
                require("snacks").indent.enable()
              end
            end

            -- Refresh lualine if available
            if package.loaded["lualine"] then
              require("lualine").refresh()
            end

            -- Ensure we have at least one normal window
            local normal_wins = 0
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              if
                ft == ""
                or ft == "lua"
                or ft == "python"
                or ft == "javascript"
                or ft == "typescript"
                or ft == "nix"
              then
                normal_wins = normal_wins + 1
              end
            end

            -- If no normal windows, create a new buffer
            if normal_wins == 0 then
              vim.cmd("enew")
            end
          end)
        end,
      })
    end,

    keys = {
      {
        "<leader>qq",
        function()
          -- Check for unsaved buffers
          local modified_buffers = {}
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= "" then
                table.insert(modified_buffers, { buf = buf, name = name })
              end
            end
          end

          -- If no modified buffers, quit normally with session save
          if #modified_buffers == 0 then
            vim.cmd("qa!")
            return
          end

          -- Handle each modified buffer with LazyVim-style floating dialog
          local function handle_next_buffer(index)
            if index > #modified_buffers then
              vim.cmd("qa!")
              return
            end

            local buffer_info = modified_buffers[index]
            local filename = vim.fn.fnamemodify(buffer_info.name, ":~:.")

            vim.ui.select({ "Yes", "No", "Cancel" }, {
              prompt = 'Save changes to "' .. filename .. '"?',
            }, function(choice)
              if choice == "Yes" then
                -- Save and continue
                vim.api.nvim_buf_call(buffer_info.buf, function()
                  vim.cmd("write")
                end)
                handle_next_buffer(index + 1)
              elseif choice == "No" then
                -- Don't save and continue
                handle_next_buffer(index + 1)
              else
                -- Cancel - do nothing
                return
              end
            end)
          end

          handle_next_buffer(1)
        end,
        desc = "Save session and quit",
      },
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").select()
        end,
        desc = "Search sessions",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Stop session saving",
      },
    },
  },
}
