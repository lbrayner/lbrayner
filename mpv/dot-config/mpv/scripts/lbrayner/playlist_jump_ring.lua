local function log(message)
  print("[playlist_jump_ring]", message)
end

local concat = table.concat

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

local utils = require("lbrayner/lib/utils")

local recent_files, recent_files_filename = {}
local recent_files_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/playlist_jump_ring"

mp.register_event("file-loaded", function()
  if not utils.is_file_loaded() then return end

  if not recent_files_filename then
    os.execute(concat{ "test -d ", recent_files_dir, " || mkdir -p ", recent_files_dir })

    local tmpname, ipc_name = os.tmpname():match("([^/\\]+)$"), utils.get_ipc_name() or ""
    recent_files_filename = concat({
      recent_files_dir, "/", ipc_name, "_", "recent_files_", tmpname, ".m3u"
    })
  end

  local filename = get_playlist_filename_at_pos(mp.get_property_native("playlist-pos-1"))

  if recent_files[filename] then
    log("Already present:", filename)
    return
  end

  recent_files[filename] = true

  local file = io.open(recent_files_filename, "a")
  file:write(concat({ filename, "\n" }))
  file:close()
  log("Appended to", recent_files_filename)
end)
