local Path = require 'plenary.path'
local Preview = require 'nvim-sidebar.preview'
local Sidebar = require 'nvim-sidebar.sidebar'

local NAMESPACE = 'nvim-sidebar.impl.git_show_commit'

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
  Sidebar.from_job {
    command = 'git',
    args = { 'show', '--name-only', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local filename = Sidebar.get_current()
  local selected = Path:new(filename)

  if selected:is_file() then
    Preview.from_file(filename, nil)
  end
end

return M
