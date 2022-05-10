local Path = require 'plenary.path'

-----------------------------
local function plugin_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return Path:new(str):parent():parent():parent()
end

-----------------------------

local M = {}

M.create_args = function(script, ...)
  local path = Path:new(plugin_path(), 'scripts', script)
  print(path)

  return { tostring(path), ... }
end

return M
