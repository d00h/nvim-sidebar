local Job = require 'plenary.job'
local Sidebar = require 'nvim-sidebar.sidebar'

local NAMESPACE = "'nvim-sidebar.impl.git_branch'"

local function setup_sidebar(bufnr)
  local opts = { noremap = true, silent = true }
  local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

  nvim_buf_set_keymap(bufnr, 'n', '<cr>', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'l', '<cmd>lua require(' .. NAMESPACE .. ').open_child()<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'h', '<cmd>Sidebar menu<cr>', opts)
  nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bdelete<cr>', opts)
end

local M = {}

M.open = function(args)
  Sidebar.from_job {
    command = 'git',
    args = { 'branch', unpack(args) },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local branch = Sidebar.get_current()
  if branch == '' then
    return
  end

  branch = string.gsub(branch, '^*?%s*', '')

  local on_exit = function(job, errorlevel)
    vim.schedule(function()
      vim.cmd 'Sidebar git_branch'
    end)
  end

  Job:new({ command = 'git', args = { 'checkout', branch }, on_exit = on_exit }):start()
end

return M
