local M = {}

local function split(args)
  local head = nil
  local tail = {}
  for idx, arg in ipairs(args) do
    if idx == 1 then
      head = arg
    else
      table.insert(tail, arg)
    end
  end
  return head, tail
end

local function command(namespace)
    local fn = function(args)
        local obj = require(namespace)
        obj.open(args)
    end
    return fn
end

M.buffers = command('nvim-sidebar.impl.buffers')
M.ag = command('nvim-sidebar.impl.ag')
M.ctags = command('nvim-sidebar.impl.ctags')
M.ls = command('nvim-sidebar.impl.ls')
M.menu = command('nvim-sidebar.impl.menu')

M.git_branch = command('nvim-sidebar.impl.git_branch')
M.git_show_commit = command('nvim-sidebar.impl.git_show_commit')
M.git_status = command('nvim-sidebar.impl.git_status')
M.git_log = command('nvim-sidebar.impl.git_log')
M.git_find_roots = command('nvim-sidebar.impl.git_find_roots')

M.docker_ps = command('nvim-sidebar.impl.docker_ps')
M.docker_images = command('nvim-sidebar.impl.docker_images')
M.docker_volumes = command('nvim-sidebar.impl.docker_volumes')

M.kubectl_get_contexts = command('nvim-sidebar.impl.kubectl_get_contexts')
M.kubectl_get_namespaces = command('nvim-sidebar.impl.kubectl_get_namespaces')
M.kubectl_get_pods = command('nvim-sidebar.impl.kubectl_get_pods')

M.sentry_find_projects = command('nvim-sidebar.impl.sentry_find_projects')
M.sentry_find_issues = command('nvim-sidebar.impl.sentry_find_issues')

M.jira_find_issues = command('nvim-sidebar.impl.jira_find_issues')

M.python_ast = command('nvim-sidebar.impl.python-ast')

M.execute = function(args)
    local cmd, argv = split(args)
    local fn = M[cmd]
    if fn == nil then
        vim.api.nvim_echo({
            {string.format('no command "%s"', cmd), "WarningMsg"}
        }, false, {})
    else
        fn(argv)
    end
end

-- nargs = 1,
-- complete = function(ArgLead, CmdLine, CursorPos)
--   return {
--     'strawberry',
--     'star',
--     'stellar',
--   }
-- end,

return M
