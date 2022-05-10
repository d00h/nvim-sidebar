local Sidebar = require 'nvim-sidebar.sidebar'
local LastPos = require 'nvim-sidebar.last_pos'

local NAMESPACE = 'nvim-sidebar.impl.kubectl_get_namespaces'

local function setup_sidebar(bufnr)
  LastPos.restore_cursor(0, NAMESPACE)
  local opts = { noremap = true, silent = true }
  local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)

  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local M = {}

M.open = function(args)
  Sidebar.from_job {
    command = 'kubectl',
    args = { 'get', 'namespaces', '--no-headers=true', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  LastPos.store_cursor(0, NAMESPACE)
  local current_line = Sidebar.get_current()
  local namespace = string.match(current_line, '^%w+')

  if namespace ~= nil then
    vim.cmd('Sidebar kubectl_get_pods --namespace=' .. namespace)
  end
end

return M
