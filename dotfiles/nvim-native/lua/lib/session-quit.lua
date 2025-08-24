local M = {}

M.quit_with_session_save = function()
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
end

return M