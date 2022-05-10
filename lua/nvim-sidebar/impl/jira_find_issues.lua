local last_pos = require 'nvim-sidebar.last_pos'
local Sidebar = require 'nvim-sidebar.sidebar'

local Preview = require 'nvim-sidebar.preview'

local NAMESPACE = 'nvim-sidebar.impl.jira_find_issues'

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }
  local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local function setup_preview(bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'json')
end

local M = {}

M.open = function(args)
  Sidebar.from_python {
    script = 'jira.py',
    args = { 'find-issues', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  last_pos.store_cursor(0, NAMESPACE)
  local current_line = Sidebar.get_current()
  local issue = string.match(current_line, '^[^:]+')

  Preview.from_python {
    script = 'jira.py',
    args = { 'get-issue', tostring(issue) },
    setup_buffer = setup_preview,
  }
end

return M
