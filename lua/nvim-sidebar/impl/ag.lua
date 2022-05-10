local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
local Sidebar = require 'nvim-sidebar.sidebar'
local Preview = require 'nvim-sidebar.preview'
local parse = require 'nvim-sidebar.parsers.ag'

local NAMESPACE = "'nvim-sidebar.impl.ag'"

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', '<c-r>', '<cmd>lua require(' .. NAMESPACE .. ').open({})<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local M = {}

M.open = function(args)
  Sidebar.from_job {
    command = 'ag',
    args = { '--group', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local selected_row  = Sidebar.get_current_row()
  local filename, row = unpack(parse(0, selected_row))

  if filename ~= nil then
    Preview.from_file(filename, row)
  end
end

return M
