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

local file_loaded, file_loaded_cb

file_loaded_cb = function()
  print("file-loaded triggered")
  if not file_loaded then
    file_loaded = true
    mp.unregister_event(file_loaded_cb)
  end
end

mp.register_event("file-loaded", file_loaded_cb)

function M.is_file_loaded()
  return file_loaded
end

return M
