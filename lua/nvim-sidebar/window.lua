local M = {}

local SIDEBAR_TAG = 'sidebar'

-- -------------------------------------------------------
local function safe_nvim_win_get_var(wnd, name, default_value)
  local success, value = pcall(function()
    return vim.api.nvim_win_get_var(wnd, name)
  end)
  if success then
    return value
  else
    return default_value
  end
end

local function create_sidebar()
  vim.cmd '40vsplit'
  local w = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_option(w, 'wrap', false)
  vim.api.nvim_win_set_option(w, 'cursorline', true)
  vim.api.nvim_win_set_var(w, SIDEBAR_TAG, true)
  return w
end

local function get_sidebar()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if safe_nvim_win_get_var(w, SIDEBAR_TAG, false) then
      return w
    end
  end
  return nil
end

-- -------------------------------------------------------

M.show = function(bufnr)
  local win = get_sidebar()
  if win == nil then
    win = create_sidebar()
  end
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.cmd('setlocal winhighlight=Normal:ColorColumn,EndOfBuffer:ColorColumn')
  return win
end

M.hide = function()
  local win = get_sidebar()
  if win ~= nil then
    vim.api.nvim_win_hide(win)
  end
end

-- -------------------------------------------------------

return M
