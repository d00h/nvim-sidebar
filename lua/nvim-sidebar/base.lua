local Job = require 'plenary.job'
local Path = require 'plenary.path'

-----------------------------------------------------------------------------
local function get_win_var(wnd, name, default_value)
  local success, value = pcall(function()
    return vim.api.nvim_win_get_var(wnd, name)
  end)
  if success then
    return value
  else
    return default_value
  end
end

local function get_buffer_var(bufnr, name, default_value)
  local success, value = pcall(function()
    return vim.api.nvim_buf_get_var(bufnr, name)
  end)
  if success then
    return value
  else
    return default_value
  end
end

local function update_buffer(bufnr, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  local last_line = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, last_line, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

-----------------------------------------------------------------------------

local function apply_job(bufnr, options)
  local command = options.command
  local args = options.args
  local setup_buffer = options.setup_buffer

  update_buffer(bufnr, { '...waiting...' })

  local on_exit = function(job, errorlevel)
    vim.schedule(function()
      update_buffer(bufnr, job:result())
      if setup_buffer ~= nil then
        setup_buffer(bufnr)
      end
    end)
  end

  Job:new({ command = command, args = args, on_exit = on_exit }):start()
end

local function apply_table(bufnr, options)
  local lines = vim.tbl_map(function(item)
    if type(item) == 'string' then
      return item
    else
      return item[1]
    end
  end, options.lines or {})
  update_buffer(bufnr, lines)

  local setup_buffer = options.setup_buffer
  if setup_buffer ~= nil then
    setup_buffer(bufnr)
  end
end

local function plugin_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  local result = Path:new(str):parent():parent():parent()
  return tostring(result)
end

local function find_buffers_with_var(varname)
  local result = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if get_buffer_var(bufnr, varname, false) then
      table.insert(result, bufnr)
    end
  end
  return result
end

local function find_windows_with_var(varname)
  local result = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if get_win_var(win, varname, false) then
      table.insert(result, win)
    end
  end
  return result
end

return {
  apply_job = apply_job,
  apply_table = apply_table,
  find_buffers_with_var = find_buffers_with_var,
  find_windows_with_var = find_windows_with_var,
  get_win_var = get_win_var,
  get_buffer_var = get_buffer_var,
  plugin_path = plugin_path,
}
