local function log(...)
  print("[playlist_autosave]", ...)
end

local concat = table.concat

local utils = require("lbrayner/lib/utils")

local playlist_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/playlists"
local playlist_name, playlist_count

mp.observe_property("playlist-count", "native", function(_, value)
  if not utils.is_file_loaded() then return end

  if playlist_count and value < playlist_count then
    playlist_name = nil
  end

  if not playlist_name then
    os.execute(concat{ "test -d ", playlist_dir, " || mkdir -p ", playlist_dir })

    local tmpname, ipc_name = os.tmpname():match("([^/\\]+)$"), utils.get_ipc_name() or ""
    playlist_name, playlist_count = concat({
      playlist_dir, "/", ipc_name, "-playlist_autosave-", tmpname, ".m3u"
    }), value

    local file = io.open(playlist_name, "w")

    for _, item in ipairs(mp.get_property_native("playlist")) do
      file:write(concat({ item.filename, "\n" }))
    end

    file:close()
    log("Saved playlist", playlist_name)
    return
  end

  local playlist = mp.get_property_native("playlist")
  local file = io.open(playlist_name, "a")

  for i = playlist_count + 1, value do
    file:write(concat({ playlist[i].filename, "\n" }))
  end

  file:close()

  log("Appended", value - playlist_count, "item(s) to playlist", playlist_name)
  playlist_count = value
end)
