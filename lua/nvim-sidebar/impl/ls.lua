local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update
local delete_all_buffers = require('nvim-sidebar.buffer').delete_all

local show_window = require('nvim-sidebar.window').show

local Job = require('plenary.job')
local Path = require('plenary.path')

local cache = {}

-- -----------------------------------------------------------------------------
local function get_current_line(win, bufnr)
    local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
    return table.concat(vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false), '')
end

local function store_cache(win)
    local cwd = vim.fn.getcwd()
    local cursor = vim.api.nvim_win_get_cursor(win)
    cache[cwd] = cursor
end

local function restore_cache(win)
    local cwd = vim.fn.getcwd()
    local cursor = cache[cwd]
    if cursor == nil then return end
    vim.api.nvim_win_set_cursor(win, cursor)
end
-- -----------------------------------------------------------------------------
local M = {}

M.setup_keys = function(bufnr)
    local opts = {noremap = true, silent = true}
    vim.api.nvim_set_keymap('n', '<cr>',
                            "<cmd>lua require('nvim-sidebar.impl.ls').open_child()<cr>",
                            opts)

    vim.api.nvim_set_keymap('n', 'l',
                            "<cmd>lua require('nvim-sidebar.impl.ls').open_child()<cr>",
                            opts)

    vim.api.nvim_set_keymap('n', 'h',
                            "<cmd>lua require('nvim-sidebar.impl.ls').open_parent()<cr>",
                            opts)

    vim.api.nvim_set_keymap('n', 'q',
                            "<cmd>bdelete<cr>",
                            opts)
end

M.open = function(args)
    if args ~= nil and #args > 0 then vim.api.nvim_set_current_dir(args[1]) end

    delete_all_buffers()

    local bufnr = create_buffer('')
    local win = show_window(bufnr)

    update_buffer(bufnr, {'...waiting...'})

    local on_exit = function(job, errorlevel)
        vim.schedule(function()
            update_buffer(bufnr, job:result())
            M.setup_keys(bufnr)
            restore_cache(win, bufnr)
        end)
    end

    Job:new({
        command = 'exa',
        args = {
            '--classify', '--oneline', '--group-directories-first', unpack(args)
        },
        on_exit = on_exit
    }):start()
end

M.open_child = function()
    store_cache(0)

    local selected = Path:new(vim.fn.getcwd(), get_current_line(0, 0))

    if selected:is_dir() then
        M.open({tostring(selected)})
        return
    end

    if selected:is_file() then
            vim.cmd('wincmd l | edit ' .. tostring(selected))
        return
    end
end

M.open_parent = function()
    local current = Path:new(vim.fn.getcwd())
    M.open({tostring(current:parent())})
end

return M
