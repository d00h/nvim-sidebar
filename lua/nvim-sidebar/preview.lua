local Job = require 'plenary.job'
local Path = require 'plenary.path'

local function update_buffer(bufnr, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  local last_line = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, last_line, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

local function from_command(options)
  local command = options.command
  local args = options.args
  local follow = options.follow
  local filetype = options.filetype

  vim.cmd 'wincmd l'
  local bufnr = vim.api.nvim_create_buf(true, true)
  --
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_win_set_buf(0, bufnr)

  update_buffer(bufnr, { '...waiting...' })

  local on_exit = function(job, errorlevel)
    vim.schedule(function()
      update_buffer(bufnr, job:result())

      if filetype ~= nil then
        vim.api.nvim_buf_set_option(bufnr, 'filetype', filetype)
      end

      if follow then
        local last_line = vim.api.nvim_buf_line_count(bufnr)
        vim.api.nvim_win_set_cursor(0, { last_line, 0 })
      end
    end)
  end

  Job:new({ command = command, args = args, on_exit = on_exit }):start()
end

local function from_script(options)
  local script = options.script
  local args = options.args or {}
  local follow = options.follow
  local filetype = options.filetype

  local str = debug.getinfo(2, 'S').source:sub(2)
  local plugin_path = Path:new(str):parent():parent():parent():parent()
  local script_path = Path:new(plugin_path, 'scripts', script)

  return from_command {
    command = 'python3',
    args = { tostring(script_path), unpack(args) },
    follow = follow,
    filetype = filetype,
  }
end

return {
  from_command = from_command,
  from_script = from_script,
}
