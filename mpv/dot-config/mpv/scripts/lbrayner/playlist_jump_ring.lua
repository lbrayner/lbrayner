local function log(...)
  print("[playlist_jump_ring]", ...)
end

local PLAYLIST_JUMP_RING = (
  "user-data/lbrayner/playlist_jump_ring/playlist_jump_ring"
)
local PLAYLIST_JUMP_RING_INDEX = (
  "user-data/lbrayner/playlist_jump_ring/playlist_jump_ring_index"
)
local backup_dir, created_backup_dir = (
  "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/playlist_jump_ring"
)
local concat = table.concat
local jump_ring_dir, jump_ring_path = (
  "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/playlist_jump_ring"
)

local utils = require("lbrayner/lib/utils")

local function backup()
  local ipc_name = utils.get_ipc_name()

  if not ipc_name then return end

  if not created_backup_dir then
    os.execute(concat{ "test -d ", backup_dir, " || mkdir -p ", backup_dir })
    created_backup_dir = true
  end

  local tmpname = os.tmpname():match("([%w_]+)$")
  local backup_path = concat({
    backup_dir, "/", ipc_name, "-playlist_jump_ring-", tmpname
  })

  local file = io.open(backup_path, "w")

  for _, item in ipairs(jump_ring) do
    file:write(concat({ item, "\n" }))
  end

  file:close()
  log("Backed up Playlist Jump Ring to", playlist_name)
end

local function get_jump_ring_path()
  if jump_ring_path then return true, jump_ring_path end

  local ipc_name = utils.get_ipc_name()

  if not ipc_name then
    return false
  end

  os.execute(concat{ "test -d ", jump_ring_dir, " || mkdir -p ", jump_ring_dir })
  jump_ring_path = concat({ jump_ring_dir, "/", ipc_name })
  os.execute(concat{ "test -f ", jump_ring_path, " || touch ", jump_ring_path })
  return true, jump_ring_path
end

mp.register_event("file-loaded", function()
  if not utils.is_file_loaded() then return end

  local jump_ring_index = mp.get_property_native(
    PLAYLIST_JUMP_RING_INDEX
  ) or {}

  local filename = mp.get_property(concat({
    "playlist/", mp.get_property("playlist-pos"), "/filename"
  }))

  if jump_ring_index[filename] then
    log("Already present:", filename)
    return
  end

  local jump_ring = mp.get_property_native(
    PLAYLIST_JUMP_RING
  ) or {}

  jump_ring_index[filename] = true
  table.insert(jump_ring, filename)
  mp.set_property_native(PLAYLIST_JUMP_RING_INDEX, jump_ring_index)
  mp.set_property_native(PLAYLIST_JUMP_RING, jump_ring)

  local _, jump_ring_path = get_jump_ring_path()

  if not jump_ring_path then
    log("Could not obtain Jump Ring path")
    return
  end

  local file = io.open(jump_ring_path, "a")
  file:write(concat({ filename, "\n" }))
  file:close()
  log("Appended to", jump_ring_path)
end)
