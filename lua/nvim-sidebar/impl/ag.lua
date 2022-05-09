local create_buffer = require('nvim-sidebar.buffer').create
local update_buffer = require('nvim-sidebar.buffer').update
local delete_all_buffers = require('nvim-sidebar.buffer').delete_all

local show_window = require('nvim-sidebar.window').show
local Job = require('plenary.job')
local Path = require('plenary.path')

local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap

local NAMESPACE = "'nvim-sidebar.impl.ag'"
-- -----------------------------------------------------------------------------
local function open_file(filename, row)
  local commands = {
    'wincmd l',
    'edit ' .. filename
  }
  if row ~= nil then
    table.insert(commands, row)
  end
  
  vim.cmd(table.concat(commands, ' | '))
end
-- -----------------------------------------------------------------------------
local M = {}

M.setup_keys = function(bufnr)
    local opts = {noremap = true, silent = true}

    nvim_buf_set_keymap(bufnr, 'n', '<cr>', "<cmd>lua require(" .. NAMESPACE ..
                            ").open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'l', "<cmd>lua require(" .. NAMESPACE ..
                            ").open_child()<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', '<c-r>',
                        "<cmd>lua require(" .. NAMESPACE .. ").open({})<cr>",
                        opts)
    nvim_buf_set_keymap(bufnr, 'n', 'j', "<cmd>Sidebar menu<cr>", opts)
    nvim_buf_set_keymap(bufnr, 'n', 'q', "<cmd>bdelete<cr>", opts)

end

M.setup_commands = function(bufnr)
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
            M.setup_commands(bufnr)
        end)
    end

    Job:new({
        command = 'ag',
        args = {'--group', unpack(args)},
        on_exit = on_exit
    }):start()
end

local function parse_line(bufnr, row)
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    local row_text = table.concat(buf_lines, '')

    if row_text == '' then return {nil, nil} end

    local found_line = string.match(row_text, '^(%d+):')
    if found_line ~= nil then return {nil, found_line} end

    local path = Path:new(row_text)

    if path:is_file() then return {tostring(path), nil} end

    return {nil, nil}
end

M.open_child = function()

    local selected_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

    local parsed_filename, parsed_row = nil, nil

    for row=selected_row,1,-1 do
      local curr_filename, curr_row = unpack(parse_line(0, row))

      if curr_row ~= nil and parsed_row == nil then
          parsed_row = curr_row
      end

      if curr_filename  ~= nil and parsed_filename == nil then
          parsed_filename = curr_filename
          break
      end
    end

    if parsed_filename ~= nil then
      open_file(parsed_filename, parsed_row)
    end

end

return M
