local function log(...)
  print("[lib/playlist_jump_ring]", ...)
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
local loaded

local utils = require("lbrayner/lib/utils")

local function backup()
  local jump_ring = mp.get_property_native(
    PLAYLIST_JUMP_RING
  ) or {}

  if not jump_ring or #jump_ring == 0 then
    log("Backup: ring empty, nothing to do")
    return
  end

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
  log("Backed up Playlist Jump Ring to", backup_path)
end

local function get_jump_ring_path()
  if jump_ring_path then return true, jump_ring_path end

  local ipc_name = utils.get_ipc_name()

  if not ipc_name then
    log("[ERROR] Could not obtain path: no IPC name")
    return false
  end

  os.execute(concat{ "test -d ", jump_ring_dir, " || mkdir -p ", jump_ring_dir })
  jump_ring_path = concat({ jump_ring_dir, "/", ipc_name })
  os.execute(concat{ "test -f ", jump_ring_path, " || touch ", jump_ring_path })
  return true, jump_ring_path
end

local M = {}

function M.add(filename)
  assert(type(filename) == "string", "'filename' must be a string")

  if not loaded then M.load() end

  local jump_ring_index = mp.get_property_native(
    PLAYLIST_JUMP_RING_INDEX
  ) or {}

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
    log("[ERROR] add: failed to synchronize", filename)
    return
  end

  local file = io.open(jump_ring_path, "a")
  file:write(concat({ filename, "\n" }))
  file:close()
  log("Appended to", jump_ring_path)
end

function M.load()
  if loaded then return end

  loaded = true

  local _, jump_ring_path = get_jump_ring_path()

  if not jump_ring_path then
    log("[ERROR] failed to load from file")
    return
  end

  local jump_ring_index, jump_ring = {}, {}

  for filename in io.lines(jump_ring_path) do
    if not jump_ring_index[filename] then
      jump_ring_index[filename] = true
      table.insert(jump_ring, filename)
    end
  end

  mp.set_property_native(PLAYLIST_JUMP_RING_INDEX, jump_ring_index)
  mp.set_property_native(PLAYLIST_JUMP_RING, jump_ring)

  log("Loaded Playlist Jump Ring")
end

function M.remove(pos)
  assert(type(pos) == "number", "'pos' must be a number")

  local jump_ring = mp.get_property_native(
    PLAYLIST_JUMP_RING
  ) or {}

  local filename = table.remove(jump_ring, pos)

  if not filename then
    log("[ERROR] Failed to remove position", pos)
    return
  end

  backup()

  local jump_ring_index = mp.get_property_native(
    PLAYLIST_JUMP_RING_INDEX
  ) or {}

  jump_ring_index[filename] = nil

  mp.set_property_native(PLAYLIST_JUMP_RING_INDEX, jump_ring_index)
  mp.set_property_native(PLAYLIST_JUMP_RING, jump_ring)

  log("Position", pos, "removed:", filename)

  local _, jump_ring_path = get_jump_ring_path()

  if not jump_ring_path then
    log("[ERROR] remove: failed to synchronize")
    return
  end

  local file = io.open(jump_ring_path, "w")

  for _, filename in ipairs(jump_ring) do
    file:write(concat({ filename, "\n" }))
  end

  file:close()
  log("Syncronized to", jump_ring_path)
end

function M.swap(pos1, pos2)
  assert(type(pos1) == "number", "'pos1' must be a number")
  assert(type(pos2) == "number", "'pos2' must be a number")

  local jump_ring = mp.get_property_native(
    PLAYLIST_JUMP_RING
  ) or {}

  local left = jump_ring[pos1]

  if not left then
    log("[ERROR] swap: position", pos1, "invalid")
    return
  end

  local right = jump_ring[pos2]

  if not right then
    log("[ERROR] swap: position", pos2, "invalid")
    return
  end

  backup()

  jump_ring[pos1] = right
  jump_ring[pos2] = left

  mp.set_property_native(PLAYLIST_JUMP_RING, jump_ring)

  log("Position", pos1, "swapped with", pos2)

  local _, jump_ring_path = get_jump_ring_path()

  if not jump_ring_path then
    log("[ERROR] swap: failed to synchronize")
    return
  end

  local file = io.open(jump_ring_path, "w")

  for _, filename in ipairs(jump_ring) do
    file:write(concat({ filename, "\n" }))
  end

  file:close()
  log("Syncronized to", jump_ring_path)
end

return M
