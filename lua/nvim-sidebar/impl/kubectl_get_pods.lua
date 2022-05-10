local base = require 'nvim-sidebar.base'
local get_buffer_var = base.get_buffer_var
local Preview = require 'nvim-sidebar.preview'
local Sidebar = require 'nvim-sidebar.sidebar'
local LastPos = require 'nvim-sidebar.last_pos'

local NAMESPACE = 'nvim-sidebar.impl.kubectl_get_pods'
local KUBECTL_ARGS = 'KUBECTL_ARGS'

local function setup_sidebar(bufnr)
  local kubectl_args = get_buffer_var(bufnr, KUBECTL_ARGS, nil ) 
  LastPos.restore_cursor(0, NAMESPACE, unpack(kubectl_args or {})) 

  local opts = { noremap = true, silent = true }
  local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', "<cmd>lua require('" .. NAMESPACE .. "').open_parent()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local function setup_preview(bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'log')
end

local M = {}

M.open = function(args)
  local bufnr = Sidebar.from_job {
    command = 'kubectl',
    args = { 'get', 'pods', '--no-headers=true', unpack(args) },
    setup_buffer = setup_sidebar,
  }

  vim.api.nvim_buf_set_var(bufnr, KUBECTL_ARGS, args)
end

M.open_child = function()

  local kubectl_args = get_buffer_var(0, KUBECTL_ARGS, {})
  LastPos.store_cursor(0, NAMESPACE, unpack(kubectl_args or {}))

  local current_line = Sidebar.get_current()
  local pod = string.match(current_line, '^%S+')

  Preview.from_job {
    command = 'kubectl',
    args = { 'logs', pod, unpack(kubectl_args) },
    setup_buffer = setup_preview,
  }
end

M.open_parent = function()
  local kubectl_args = get_buffer_var(0, KUBECTL_ARGS, {})
  LastPos.store_cursor(0, NAMESPACE, unpack(kubectl_args or {}))

  vim.cmd 'Sidebar kubectl_get_namespaces'
end

return M
