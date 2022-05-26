local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
local Sidebar = require 'nvim-sidebar.sidebar'
local Preview = require 'nvim-sidebar.preview'

local NAMESPACE = 'nvim-sidebar.impl.ctags'

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', '<cmd>lua require("' .. NAMESPACE .. '").open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', '<cmd>lua require("' .. NAMESPACE .. '").open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', '<c-r>', '<cmd>lua require("' .. NAMESPACE .. '").open({})<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local M = {}

M.open = function(args)
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    return
  end
  Sidebar.from_python {
    script = 'ctags.py',
    args = { name },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local selected = Sidebar.get_current()
  Preview.from_file { text = selected }
end

return M
