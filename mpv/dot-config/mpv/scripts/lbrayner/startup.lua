local function log(...)
  print("[startup]", ...)
end

local file_loaded, file_loaded_cb

file_loaded_cb = function()
  log("file-loaded triggered")
  if not file_loaded then
    file_loaded = true
    mp.unregister_event(file_loaded_cb)
  end
end

mp.register_event("file-loaded", file_loaded_cb)

local M = {}

function M.is_file_loaded()
  return file_loaded
end

return M
