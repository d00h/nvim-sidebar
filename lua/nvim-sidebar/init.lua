local Buffer = require('nvim-sidebar.buffer')
local Window = require('nvim-sidebar.window')
local cmdline  = require('nvim-sidebar.cmdline')

local M = {}

local function command(namespace)
    local fn = function(args)
        local obj = require(namespace)
        obj.open(args)
    end
    return fn
end

M.ls = command('nvim-sidebar.impl.ls')
M.git_status = command('nvim-sidebar.impl.git_status')
M.kubectl_get_namespaces = command('nvim-sidebar.impl.kubectl_get_namespaces')
M.kubectl_get_pods = command('nvim-sidebar.impl.kubectl_get_pods')

M.execute = function(args)
  local command, argv = cmdline.split(args)
  local fn = M[command]
  if fn == nil then
    vim.api.nvim_echo({{'no command',  "WarningMsg"}}, false, {})
  else
    fn(argv)
  end
end

return M
