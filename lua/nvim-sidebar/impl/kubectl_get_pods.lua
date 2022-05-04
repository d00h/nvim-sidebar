local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update
local delete_all_buffers = require('nvim-sidebar.buffer').delete_all
local get_current_line = require('nvim-sidebar.buffer').get_current_line

local show_window = require('nvim-sidebar.window').show

local Job = require('plenary.job')

local NAMESPACE = 'nvim-sidebar.impl.kubectl_get_pods'
-- -----------------------------------------------------------------------------
local M = {}
local last_namespace = nil

M.setup_keys = function(bufnr)
    local opts = {noremap = true, silent = true}
    local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

    nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE .. "').open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'h', "<cmd>lua require('" .. NAMESPACE .. "').open_parent()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'q', "<cmd>bdelete<cr>", opts)
end

M.open = function(args)
    delete_all_buffers()

    local bufnr = create_buffer('')
    local win = show_window(bufnr)

    update_buffer(bufnr, {'...waiting...'})

    local on_exit = function(job, errorlevel)
        vim.schedule(function()
            update_buffer(bufnr, job:result())
            M.setup_keys(bufnr)
        end)
    end

    Job:new({
        command = 'kubectl',
        args = {'get', 'pods','--no-headers=true', unpack(args)},
        on_exit = on_exit
    }):start()

end

M.open_child = function()
    local current_line = get_current_line(0, 0)
    local pod = string.match(current_line, '^%S+')

    vim.cmd('wincmd l')

    local bufnr = vim.api.nvim_create_buf(true, true)
    --
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_win_set_buf(0, bufnr)

    update_buffer(bufnr, {'...waiting...' })

    local on_exit = function(job, errorlevel)
        vim.schedule(function()
            update_buffer(bufnr, job:result())
            local last_line = vim.api.nvim_buf_line_count(bufnr)
            vim.api.nvim_win_set_cursor(0, { last_line, 0})

        end)
    end
    
    Job:new({
        command = 'kubectl',
        args = {'logs', pod, '--namespace=dev4'},
        on_exit = on_exit
    }):start()
end

M.open_parent = function()
  vim.cmd('Sidebar kubectl_get_namespaces')
end

return M
