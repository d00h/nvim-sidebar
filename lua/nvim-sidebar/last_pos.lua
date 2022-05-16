local M = {}
local cache = {}

M.store_cursor = function(win, key, ...)
  key = table.concat({ key, ... }, '_')
  local cursor = vim.api.nvim_win_get_cursor(win)
  cache[key] = cursor
end

M.restore_cursor = function(win, key, ...)
  key = table.concat({ key, ... }, '_')
  local cursor = cache[key]
  if cursor == nil then
    return
  end
  local bufnr = vim.api.nvim_win_get_buf(0)
  local last_line = vim.api.nvim_buf_line_count(bufnr)
  if cursor[1] > last_line then
    return
  end
  vim.api.nvim_win_set_cursor(win, cursor)
end

return M
