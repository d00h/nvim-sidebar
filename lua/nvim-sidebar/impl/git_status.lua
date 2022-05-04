local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update
local delete_all_buffers = require('nvim-sidebar.buffer').delete_all

local show_window = require('nvim-sidebar.window').show

local Job = require('plenary.job')
local Path = require('plenary.path')

---
local function get_current_line(win, bufnr)
    local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
    return table.concat(vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false), '')
end

----
--
local M = {}

M.setup_keys = function(bufnr)
    local opts = {noremap = true, silent = true}
    local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

    nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require('nvim-sidebar.impl.git_status').open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require('nvim-sidebar.impl.git_status').open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'q', "<cmd>bdelete<cr>", opts)
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
        end)
    end

    Job:new({
        command = 'git',
        args = {'status', '--short', unpack(args)},
        on_exit = on_exit
    }):start()
end

M.open_child = function()
  local current_line =get_current_line(0, 0)
  local filename = string.gsub(current_line, '^%s*%w+%s+', '')
  local selected = Path:new(filename)

  if selected:is_file() then
      vim.cmd('wincmd l | edit ' .. tostring(selected))
  end
end

return M
