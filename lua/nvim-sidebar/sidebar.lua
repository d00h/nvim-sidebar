local base = require 'nvim-sidebar.base'
local apply_job = base.apply_job
local apply_table = base.apply_table
local find_buffers_with_var = base.find_buffers_with_var
local find_windows_with_var = base.find_windows_with_var
local Path = require 'plenary.path'
local plugin_path = base.plugin_path

local SIDEBAR_TAG = 'SIDEBAR'

---
local function show_sidebar_window(bufnr)
  local win = find_windows_with_var(SIDEBAR_TAG)[0]

  if win == nil then
    vim.cmd '40vsplit'
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_var(win, SIDEBAR_TAG, true)
  end

  vim.api.nvim_win_set_buf(win, bufnr)
  vim.cmd 'setlocal winhighlight=Normal:ColorColumn,EndOfBuffer:ColorColumn'

  return win
end

local function create_sidebar_buffer(name)
  for _, bufnr in ipairs(find_buffers_with_var(SIDEBAR_TAG)) do
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end

  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.api.nvim_buf_set_var(bufnr, SIDEBAR_TAG, true)
  return bufnr
end

---

local function from_job(options)
  local bufnr = create_sidebar_buffer ''
  show_sidebar_window(bufnr)

  apply_job(bufnr, {
    command = options.command,
    args = options.args,
    setup_buffer = options.setup_buffer,
  })
  return bufnr
end

local function from_python(options)
  local script_path = Path:new(plugin_path(), 'scripts', options.script)

  return from_job {
    command = 'python3',
    args = { tostring(script_path), unpack(options.args or {}) },
    setup_buffer = options.setup_buffer,
  }
end

local function from_table(options)
  local bufnr = create_sidebar_buffer ''
  show_sidebar_window(bufnr)
  apply_table(bufnr, {
    lines = options.lines,
    setup_buffer = options.setup_buffer,
  })
  return bufnr
end

local function get_current_row()
  for _, win in ipairs(find_windows_with_var(SIDEBAR_TAG)) do
    for _, bufnr in ipairs(find_buffers_with_var(SIDEBAR_TAG)) do
      local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
      return row
    end
  end
end

local function get_current()
  for _, win in ipairs(find_windows_with_var(SIDEBAR_TAG)) do
    for _, bufnr in ipairs(find_buffers_with_var(SIDEBAR_TAG)) do
      local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
      return table.concat(vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false), '')
    end
  end
end

return {
  get_current = get_current,
  get_current_row = get_current_row,
  from_job = from_job,
  from_python = from_python,
  from_table = from_table,
}
