local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
local Path = require 'plenary.path'
local Preview = require 'nvim-sidebar.preview'
local Sidebar = require 'nvim-sidebar.sidebar'
local LastPos = require 'nvim-sidebar.last_pos'

local NAMESPACE = "'nvim-sidebar.impl.ls'"

local function setup_sidebar(bufnr)
  LastPos.restore_cursor(0, NAMESPACE, vim.fn.getcwd())

  local opts = { noremap = true, silent = true }

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>lua require(' .. NAMESPACE .. ').open_parent()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', '<c-r>', '<cmd>lua require(' .. NAMESPACE .. ').open({})<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)

  nvim_buf_create_user_command(bufnr, 'Mkfile', function(a)
    Preview.from_file { filename = a['args'] }
  end, { nargs = 1 })

  nvim_buf_create_user_command(bufnr, 'Mkdir', function(a)
    os.execute('mkdir ' .. a['args'])
    vim.cmd 'Sidebar ls'
  end, { nargs = 1 })

  nvim_buf_create_user_command(bufnr, 'Rename', function(a)
    local selected = Path:new(vim.fn.getcwd(), Sidebar.get_current())
    if selected:exists() then
      os.execute('mv ' .. tostring(selected) .. ' ' .. a['args'])
      vim.cmd 'Sidebar ls'
    end
  end, { nargs = 1 })
end

local M = {}

M.open = function(args)
  if args ~= nil and #args > 0 then
    vim.api.nvim_set_current_dir(args[1])
  end
  Sidebar.from_job {
    command = 'exa',
    args = { '--classify', '--oneline', '--group-directories-first', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  LastPos.store_cursor(0, NAMESPACE, vim.fn.getcwd())

  local selected = Path:new(vim.fn.getcwd(), Sidebar.get_current())

  if selected:is_dir() then
    vim.cmd('Sidebar ls ' .. tostring(selected))
    return
  end

  if selected:is_file() then
    Preview.from_file { filename = tostring(selected) }
    return
  end
end

M.open_parent = function()
  local current = Path:new(vim.fn.getcwd())
  vim.cmd('Sidebar ls ' .. tostring(current:parent()))
end

return M
