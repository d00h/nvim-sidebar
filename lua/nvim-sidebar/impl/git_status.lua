local Buffer = require('nvim-sidebar.buffer')
local Window = require('nvim-sidebar.window')

local function open(args)
  local bufnr = Buffer.from_shell('git', 'status', '--short')
  Window.create(bufnr)
end


return {
  open = open
}
