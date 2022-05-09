local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update
local delete_all_buffers = require('nvim-sidebar.buffer').delete_all
local get_current_line = require('nvim-sidebar.buffer').get_current_line

local show_window = require('nvim-sidebar.window').show
local Job = require 'plenary.job'
local Path = require 'plenary.path'

local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

local NAMESPACE = "'nvim-sidebar.impl.ls'"
-- -----------------------------------------------------------------------------
local cache = {}

local function store_cache(win)
  local cwd = vim.fn.getcwd()
  local cursor = vim.api.nvim_win_get_cursor(win)
  cache[cwd] = cursor
end

local function restore_cache(win)
  local cwd = vim.fn.getcwd()
  local cursor = cache[cwd]
  if cursor == nil then
    return
  end
  vim.api.nvim_win_set_cursor(win, cursor)
end
-- -----------------------------------------------------------------------------
local function open_file(filename)
  vim.cmd('wincmd l | edit ' .. filename)
end
-- -----------------------------------------------------------------------------
local M = {}

M.setup_keys = function(bufnr)
  local opts = { noremap = true, silent = true }

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>lua require(' .. NAMESPACE .. ').open_parent()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', '<c-r>', '<cmd>lua require(' .. NAMESPACE .. ').open({})<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

M.setup_commands = function(bufnr)
  nvim_buf_create_user_command(bufnr, 'Mkfile', function(a)
    open_file(a['args'])
  end, { nargs = 1 })

  nvim_buf_create_user_command(bufnr, 'Mkdir', function(a)
    os.execute('mkdir ' .. a['args'])
    vim.cmd 'Sidebar ls'
  end, { nargs = 1 })

  nvim_buf_create_user_command(bufnr, 'Rename', function(a)
    local selected = Path:new(vim.fn.getcwd(), get_current_line(0, 0))
    if selected:exists() then
      os.execute('mv ' .. tostring(selected) .. ' ' .. a['args'])
      vim.cmd 'Sidebar ls'
    end
  end, { nargs = 1 })
end

M.open = function(args)
  if args ~= nil and #args > 0 then
    vim.api.nvim_set_current_dir(args[1])
  end

  delete_all_buffers()

  local bufnr = create_buffer ''
  local win = show_window(bufnr)

  update_buffer(bufnr, { '...waiting...' })

  local on_exit = function(job, errorlevel)
    vim.schedule(function()
      update_buffer(bufnr, job:result())
      M.setup_keys(bufnr)
      M.setup_commands(bufnr)
      restore_cache(win, bufnr)
    end)
  end

  Job
    :new({
      command = 'exa',
      args = {
        '--classify',
        '--oneline',
        '--group-directories-first',
        unpack(args),
      },
      on_exit = on_exit,
    })
    :start()
end

M.open_child = function()
  store_cache(0)

  local selected = Path:new(vim.fn.getcwd(), get_current_line(0, 0))

  if selected:is_dir() then
    vim.cmd('Sidebar ls ' .. tostring(selected))
    return
  end

  if selected:is_file() then
    open_file(tostring(selected))
    return
  end
end

M.open_parent = function()
  local current = Path:new(vim.fn.getcwd())
  vim.cmd('Sidebar ls ' .. tostring(current:parent()))
end

return M
