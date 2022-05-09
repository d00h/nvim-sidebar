local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update
local delete_all_buffers = require('nvim-sidebar.buffer').delete_all
local get_current_line = require('nvim-sidebar.buffer').get_current_line

local show_window = require('nvim-sidebar.window').show

local Job = require('plenary.job')

local NAMESPACE = 'nvim-sidebar.impl.kubectl_get_contexts'
-- -----------------------------------------------------------------------------
local M = {}

M.setup_keys = function(bufnr)
    local opts = {noremap = true, silent = true}
    local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

    nvim_buf_set_keymap(bufnr, 'n', '<cr>',
                        "<cmd>lua require('" .. NAMESPACE ..
                            "').open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('" .. NAMESPACE ..
                            "').open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'h', "<cmd>Sidebar menu<cr>", opts)
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
        args = {
            'config', 'get-contexts', '--no-headers=true', '--output=name',
            unpack(args)
        },
        on_exit = on_exit
    }):start()

end

M.open_child = function()
    local context = get_current_line(0, 0)

    if context == '' then return end

    local on_exit = function(job, errorlevel)
        vim.schedule(function()
            vim.cmd('Sidebar kubectl_get_namespaces')
        end)
    end

    Job:new({
        command = 'kubectl',
        args = {'config', 'set-context', context},
        on_exit = on_exit
    }):start()

end

return M
