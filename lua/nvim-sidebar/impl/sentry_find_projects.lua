local Sidebar = require 'nvim-sidebar.sidebar'

local NAMESPACE = 'nvim-sidebar.impl.sentry_find_projects'

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }
  local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local M = {}

M.open = function(args)
  Sidebar.from_python {
    script = 'sentry.py',
    args = { 'find-projects', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local selected = Sidebar.get_current()
  vim.cmd('Sidebar sentry_find_issues ' .. tostring(selected))
end

return M
