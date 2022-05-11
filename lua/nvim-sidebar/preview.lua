local base = require 'nvim-sidebar.base'
local apply_job = base.apply_job
local plugin_path = base.plugin_path

local Path = require 'plenary.path'

local function from_job(options)
  vim.cmd 'wincmd l'
  local bufnr = vim.api.nvim_create_buf(true, true)

  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_win_set_buf(0, bufnr)

  apply_job(bufnr, {
    command = options.command,
    args = options.args,
    setup_buffer = options.setup_buffer,
  })
end

local function from_python(options)
  local script_path = Path:new(plugin_path(), 'scripts', options.script)

  return from_job {
    command = 'python3',
    args = { tostring(script_path), unpack(options.args or {}) },
    setup_buffer = options.setup_buffer,
  }
end

local function from_file(options)
  local filename = options.filename
  local pattern = options.pattern
  local row = options.row
  local commands = { 'wincmd l' }

  if filename ~= nil then
    table.insert(commands, 'edit ' .. filename)
  end

  if pattern ~= nil then
    table.insert(commands, '/' .. pattern .. '/')
  end

  if row ~= nil then
    table.insert(commands, row)
  end

  vim.cmd(table.concat(commands, ' | '))
end

return {
  from_job = from_job,
  from_python = from_python,
  from_file = from_file,
}
