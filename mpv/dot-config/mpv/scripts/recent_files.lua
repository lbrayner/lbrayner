local concat = table.concat

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

local file_loaded, file_loaded_cb
local recent_files, recent_files_filename = {}
local recent_files_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/recent_files"

mp.register_event("file-loaded", function()
  if not file_loaded then return end

  if not recent_files_filename then
    os.execute(concat{ "test -d ", recent_files_dir, " || mkdir -p ", recent_files_dir })

    local tmpname = os.tmpname():match("([^/\\]+)$")
    recent_files_filename = concat({ recent_files_dir, "/", "recent_files_", tmpname, ".m3u" })
  end

  local filename = get_playlist_filename_at_pos(mp.get_property_native("playlist-pos-1"))

  if recent_files[filename] then
    print("Already present:", filename)
    return
  end

  recent_files[filename] = true

  local file = io.open(recent_files_filename, "a")
  file:write(concat({ filename, "\n" }))
  file:close()
  print("Appended to", recent_files_filename)
end)

file_loaded_cb = function()
  print("file-loaded triggered")
  if not file_loaded then
    file_loaded = true
    mp.unregister_event(file_loaded_cb)
  end
end

mp.register_event("file-loaded", file_loaded_cb)
