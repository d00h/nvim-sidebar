local Path = require 'plenary.path'

-----------------------------
local function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  local path = Path:new(str)
  return path:parent()
end

-----------------------------

local M = {}

M.create_args = function(script, ...)
  local path = Path:new(script_path(), script)

  return { tostring(path), ... }
end

return M
