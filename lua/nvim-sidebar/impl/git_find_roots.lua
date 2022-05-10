local Sidebar = require 'nvim-sidebar.sidebar'
local Path = require 'plenary.path'

local NAMESPACE = 'nvim-sidebar.impl.git_find_roots'
-- -----------------------------------------------------------------------------

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }
  local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local find_projects = {
  'fd --max-depth=4 --type directory '
    .. '--search-path=${HOME} '
    .. '--hidden '
    .. '--exclude=.bck '
    .. '--exclude=.cache '
    .. '--exclude=.config '
    .. '--exclude=.password-store '
    .. '--exclude=.local '
    .. '"\\.git" ',
  'xargs -n1 dirname',
  'uniq',
}

local M = {}

M.open = function(args)
  Sidebar.from_job {
    command = 'sh',
    args = { '-c', table.concat(find_projects, ' | '), unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local selected = Path:new(Sidebar.get_current())

  if selected:is_dir() then
    vim.cmd('Sidebar ls ' .. tostring(selected))
  end
end

return M
