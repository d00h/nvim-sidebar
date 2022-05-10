--
-- parse something like
--
-- filename.ext
-- 10: message1
--
-- to { filename:row }
--

local Path = require 'plenary.path'

local function parse_line(bufnr, row)
  local buf_lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
  local row_text = table.concat(buf_lines, '')

  if row_text == '' then
    return { nil, nil }
  end

  local found_line = string.match(row_text, '^(%d+):')
  if found_line ~= nil then
    return { nil, found_line }
  end

  local path = Path:new(row_text)

  if path:is_file() then
    return { tostring(path), nil }
  end

  return { nil, nil }
end

local function get_filename_and_row(bufnr, selected_row)
  local parsed_filename, parsed_row = nil, nil

  for row = selected_row, 1, -1 do
    local curr_filename, curr_row = unpack(parse_line(bufnr, row))

    if curr_row ~= nil and parsed_row == nil then
      parsed_row = curr_row
    end

    if curr_filename ~= nil and parsed_filename == nil then
      parsed_filename = curr_filename
      break
    end
  end
  return { parsed_filename, parsed_row }
end

return get_filename_and_row
