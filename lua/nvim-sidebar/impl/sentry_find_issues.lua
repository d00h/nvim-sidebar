local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
local Preview = require 'nvim-sidebar.preview'
local Sidebar = require 'nvim-sidebar.sidebar'

local NAMESPACE = 'nvim-sidebar.impl.sentry_find_issues'

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }

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
    script = 'sentry.py',
    args = { 'find-issues', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local current_line = Sidebar.get_current()
  local issue = string.match(current_line, '^%d+')

  Preview.from_python {
    script = 'sentry.py',
    args = { 'cat-issue', tostring(issue) },
    setup_buffer = setup_preview,
  }
end

return M
