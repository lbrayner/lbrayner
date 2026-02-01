local concat = table.concat
local file_loaded, file_loaded_cb

file_loaded_cb = function()
  print("file-loaded triggered")
  if not file_loaded then
    file_loaded = true
    mp.unregister_event(file_loaded_cb)
  end
end

mp.register_event("file-loaded", file_loaded_cb)

local playlist_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/playlist-backup"
local playlist_name, playlist_count

mp.observe_property('playlist-count', 'native', function(_, value)
  if not file_loaded then return end

  if playlist_count and value < playlist_count then
    playlist_name = nil
  end

  playlist_count = value

  if not playlist_name then
    os.execute(concat{ "test -d ", playlist_dir, " || mkdir -p ", playlist_dir })

    local tmpname = os.tmpname():match("([^/\\]+)$")
    playlist_name = concat({ playlist_dir, "/", tmpname, ".m3u" })

    local file = io.open(playlist_name, "w")

    for _, item in ipairs(mp.get_property_native("playlist")) do
      file:write(concat({ item.filename, "\n" }))
    end

    file:close()
    print("Saved playlist", playlist_name)
    return
  end

  local playlist = mp.get_property_native("playlist")
  local last_item = playlist[#playlist]
  local file = io.open(playlist_name, "a")
  file:write(concat({ last_item.filename, "\n" }))
  file:close()
  print("Appended to playlist", playlist_name)
end)
