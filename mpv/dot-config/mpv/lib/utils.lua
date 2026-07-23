local M = {}

local ipc_name

function M.get_ipc_name()
  if ipc_name ~= nil then return ipc_name end

  ipc_name = mp.get_property("input-ipc-server"):match("([%w_]+)$")

  if not ipc_name then
    ipc_name = false
  end

  return ipc_name
end

return M
