local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
local NAMESPACE = 'nvim-sidebar.impl.buffers'
local Sidebar = require 'nvim-sidebar.sidebar'

local function find_buffers()
  local result = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname == '' then
        bufname = 'unnamed'
      end
      table.insert(result, string.format('%d. %s', bufnr, bufname))
    end
  end
  return result
end

local function get_buffer_by_row(row)
  for bufrow, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if bufrow == row then
      return bufnr
    end
  end
  return -1
end

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local M = {}

M.open = function(args)
  Sidebar.from_table {
    lines = find_buffers(),
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local bufnr = get_buffer_by_row(row)
  if bufnr ~= -1 then
    vim.cmd('wincmd l | buffer ' .. tostring(bufnr))
  end
end

return M
