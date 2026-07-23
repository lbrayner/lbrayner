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

local extended_playlist_items_by_filename

function M.get_extended_playlist_items_by_filename(filename)
  if extended_playlist_items_by_filename then
    return extended_playlist_items_by_filename[filename] or {}
  end

  extended_playlist_items_by_filename = {}

  for i, item in ipairs(mp.get_property_native("playlist")) do
    if not extended_playlist_items_by_filename[item.filename] then
      extended_playlist_items_by_filename[item.filename] = {}
    end

    item.pos = i
    table.insert(extended_playlist_items_by_filename[item.filename], item)
  end

  return extended_playlist_items_by_filename[filename] or {}
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
