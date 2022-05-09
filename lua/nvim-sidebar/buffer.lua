local Job = require 'plenary.job'

local SIDEBAR_TAG = 'sidebar'

-- ---------------------------------------------------------------------------

local M = {}

M.get_var = function(bufnr, name, default_value)
  local success, value = pcall(function()
    return vim.api.nvim_buf_get_var(bufnr, name)
  end)
  if success then
    return value
  else
    return default_value
  end
end

M.delete_all = function()
  for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if M.get_var(bufnr, SIDEBAR_TAG, false) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end
end

M.create = function(name)
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.api.nvim_buf_set_var(bufnr, SIDEBAR_TAG, true)
  return bufnr
end

M.update = function(bufnr, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  local last_line = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, last_line, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

M.get_current_line = function(win, bufnr)
  local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false), '')
end

M.update_from_job = function(bufnr, command, args)
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_win_set_buf(0, bufnr)

  M.update(bufnr, { '...waiting...' })

  local on_exit = function(job, errorlevel)
    vim.schedule(function()
      M.update(bufnr, job:result())
      local last_line = vim.api.nvim_buf_line_count(bufnr)
      vim.api.nvim_win_set_cursor(0, { last_line, 0 })
    end)
  end

  Job:new({ command = command, args = args, on_exit = on_exit }):start()
end

return M
