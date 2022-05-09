local delete_all_buffers = require('nvim-sidebar.buffer').delete_all
local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update

local get_buffer_var = require('nvim-sidebar.buffer').get_var

local show_window = require('nvim-sidebar.window').show
local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap


local default_menu = {
  '# General',
  '',
  {'* Buffers', 'Sidebar buffers'},
  {'* Files', 'Sidebar ls'},
  {'* Todo', 'Sidebar ag (TODO|BUG|FIXME|KLUDGE|BOOKMARK):'},
  '',
  '# Git',
  '',
  {'* Status',      'Sidebar git_status'},
  {'* Branch',      'Sidebar git_branch'},
  {'* Last commit', 'Sidebar git_show_commit -1'},
  {'* Log',         'Sidebar git_log'},
  {'* Find roots',  'Sidebar git_find_roots'},
  '',
  '# Kubernates',
  '',
  {'* Contexts',   'Sidebar kubectl_get_contexts'},
  {'* Namespaces', 'Sidebar kubectl_get_namespaces'},
  '',
  '# Python',
  '',
  {'* Routes',   'Sidebar python_ast find-decorators ^route$'},
  {'* Tests',    'Sidebar python_ast find-functions ^test_'},
  {'* Fixtures', 'Sidebar python_ast find-decorators ^fixture$'},
  '',
  '# Jira ',
  '',
  {'* Issues', 'Sidebar jira_find_issues project=bil'},
  '',
  '# Sentry',
  '',
  {'* Projects', 'Sidebar sentry_find_projects'},
  {'* Issues',   'Sidebar sentry_find_issues ururu'},
}

local MENU_TAG = 'menu'
---------------------
local function prepare_menu(menu)
  local result = {}
  for _, menu_item in pairs(menu) do
      if type(menu_item) == 'string' then
        table.insert(result, menu_item)
      else
        table.insert(result, menu_item[1])
      end
  end
  return result
end
---------------------

local M = {}

local NAMESPACE = "'nvim-sidebar.impl.menu'"

M.setup_keys = function(bufnr)
    local opts = {noremap = true, silent = true}

    nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require(" .. NAMESPACE .. ").open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require(" .. NAMESPACE .. ").open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'q', "<cmd>bdelete<cr>", opts)
end

M.open = function(args)
    delete_all_buffers()

    local bufnr = create_buffer('')
    local win = show_window(bufnr)
    local current_menu = default_menu

    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'markdown')
    vim.api.nvim_buf_set_var(bufnr, MENU_TAG, current_menu)
    M.setup_keys(bufnr)

    update_buffer(bufnr, prepare_menu(current_menu))
end

M.open_child = function()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local current_menu = get_buffer_var(0, MENU_TAG)

    if current_menu == nil then
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
