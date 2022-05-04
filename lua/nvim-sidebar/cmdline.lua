
local M = {}

M.split = function(args)
  local head = nil
  local tail = {}
  for idx, arg  in ipairs(args) do
    if idx == 1 then
      head = arg
    else
      table.insert(tail, arg)
    end
  end
  return head, tail
end

return M
