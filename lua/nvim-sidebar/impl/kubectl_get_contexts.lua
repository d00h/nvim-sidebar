local Job = require 'plenary.job'
local Sidebar = require 'nvim-sidebar.sidebar'

local NAMESPACE = 'nvim-sidebar.impl.kubectl_get_contexts'
-- -----------------------------------------------------------------------------

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
    command = 'kubectl',
    args = {
      'config',
      'get-contexts',
      '--no-headers=true',
      '--output=name',
      unpack(args),
    },
    setup_buffer = setup_sidebar,
  }
end

M.open_child = function()
  local context = Sidebar.get_current()
  if context == '' then
    return
  end

  local on_exit = function(job, errorlevel)
    vim.schedule(function()
      vim.cmd 'Sidebar kubectl_get_namespaces'
    end)
  end

  Job
    :new({
      command = 'kubectl',
      args = { 'config', 'set-context', context },
      on_exit = on_exit,
    })
    :start()
end

return M
