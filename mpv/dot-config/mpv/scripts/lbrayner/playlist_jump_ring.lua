local function log(...)
  print("[playlist_jump_ring]", ...)
end

local concat = table.concat

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

local utils = require("lbrayner/lib/utils")

local PLAYLIST_JUMP_RING = (
  "user-data/lbrayner/playlist_jump_ring/playlist_jump_ring"
)
local jump_ring, jump_ring_index, jump_ring_filename = {}, {}
local jump_ring_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/playlist_jump_ring"

mp.register_event("file-loaded", function()
  if not utils.is_file_loaded() then return end

  if not jump_ring_filename then
    os.execute(concat{ "test -d ", jump_ring_dir, " || mkdir -p ", jump_ring_dir })

    local tmpname, ipc_name = os.tmpname():match("([^/\\]+)$"), utils.get_ipc_name() or ""
    jump_ring_filename = concat({
      jump_ring_dir, "/", ipc_name, "-playlist_jump_ring-", tmpname, ".m3u"
    })
  end

  local filename = get_playlist_filename_at_pos(mp.get_property_native("playlist-pos-1"))

  if jump_ring_index[filename] then
    log("Already present:", filename)
    return
  end

  jump_ring_index[filename] = true
  table.insert(jump_ring, filename)
  mp.set_property_native(PLAYLIST_JUMP_RING, jump_ring)

  local file = io.open(jump_ring_filename, "a")
  file:write(concat({ filename, "\n" }))
  file:close()
  log("Appended to", jump_ring_filename)
end)
