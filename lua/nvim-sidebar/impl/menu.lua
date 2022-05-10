local LastPos = require 'nvim-sidebar.last_pos'
local Sidebar = require 'nvim-sidebar.sidebar'
local get_buffer_var = require('nvim-sidebar.base').get_buffer_var
local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

local default_menu = {
  '# General',
  '',
  { '* Buffers', 'Sidebar buffers' },
  { '* Files', 'Sidebar ls' },
  { '* Todo', 'Sidebar ag (TODO|BUG|FIXME|KLUDGE|BOOKMARK):' },
  '',
  '# Git',
  '',
  { '* Status', 'Sidebar git_status' },
  { '* Branch', 'Sidebar git_branch' },
  { '* Last commit', 'Sidebar git_show_commit -1' },
  { '* Log', 'Sidebar git_log' },
  { '* Find roots', 'Sidebar git_find_roots' },
  '',
  '# Docker',
  '',
  { '* Ps', 'Sidebar docker_ps' },
  { '* Images', 'Sidebar docker_images' },
  { '* Volumes', 'Sidebar docker_volumes' },
  '',
  '# Kubernates',
  '',
  { '* Contexts', 'Sidebar kubectl_get_contexts' },
  { '* Namespaces', 'Sidebar kubectl_get_namespaces' },
  '',
  '# Python',
  '',
  { '* Routes', 'Sidebar python_ast find-decorators ^route$' },
  { '* Tests', 'Sidebar python_ast find-functions ^test_' },
  { '* Fixtures', 'Sidebar python_ast find-decorators ^fixture$' },
  '',
  '# Jira ',
  '',
  { '* Issues', 'Sidebar jira_find_issues project=bil' },
  '',
  '# Sentry',
  '',
  { '* Projects', 'Sidebar sentry_find_projects' },
  { '* Issues', 'Sidebar sentry_find_issues ururu' },
}

local MENU_TAG = 'menu'

local M = {}

local NAMESPACE = "'nvim-sidebar.impl.menu'"

local function setup_sidebar(bufnr)
  LastPos.restore_cursor(0, NAMESPACE)

  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'markdown')

  local opts = { noremap = true, silent = true }

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

M.open = function(args)
  local current_menu = default_menu
  local bufnr = Sidebar.from_table {
    lines = current_menu,
    setup_buffer = setup_sidebar,
  }
  vim.api.nvim_buf_set_var(bufnr, MENU_TAG, current_menu)
end

M.open_child = function()
  LastPos.store_cursor(0, NAMESPACE)

  local row = Sidebar.get_current_row()
  local current_menu = get_buffer_var(0, MENU_TAG)

  if current_menu == nil or row == nil then
    return
  end

  local menu_item = current_menu[row]
  if menu_item == nil then
    return
  end

  local command = menu_item[2]
  if command == nil then
    return
  end

  vim.cmd(command)
end

return M
