local home = os.getenv("MPV_CONFIG_HOME")
local vendor = os.getenv("MPV_VENDOR_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

if not vendor or vendor == "" then
  print("MPV_VENDOR_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({
  package.path,
  concat({ home, "lib/?.lua" }, "/"),
  concat({ vendor, "lib/?.lua" }, "/")
}, ";")

local control = require("control")
local json = require("json")
local marks_backup_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/marks"
local marks_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/marks"

local ipc_name, marks_path
local marks = {}

local function get_ipc_name()
  if ipc_name then return ipc_name end

  ipc_name = mp.get_property("input-ipc-server"):match("([^/\\]+)$")

  if not ipc_name then
    ipc_name = false
  end

  return ipc_name
end

local function get_marks_path()
  if marks_path then return marks_path end

  local ipc_name = get_ipc_name()

  if not ipc_name then
    marks_path = false
    return
  end

  os.execute(concat{ "test -d ", marks_dir, " || mkdir -p ", marks_dir })
  marks_path = concat({ marks_dir, "/", ipc_name })
  return marks_path
end

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

local function jump_to_mark(slot)
  if not marks[slot] then
    mp.osd_message(concat({ "Mark", slot, "no set" }, " "))
    return
  end

  local pos = marks[slot].pos
  local filename = get_playlist_filename_at_pos(pos)

  if filename ~= marks[slot].filename then
    mp.osd_message(concat({ "Mark", slot, "invalid" }, " "))
    return
  end

  control.playlist_jump_to_position(marks[slot].pos)
end

local function save_marks()
  local marks_path = get_marks_path()

  if not marks_path then return end

  local marks_file = io.open(marks_path, "w")
  marks_file:write(concat({ json.encode(marks), "\n" }))
  marks_file:close()
end

local function set_mark(slot)
  local pos = mp.get_property_native("playlist-pos-1")
  local filename = get_playlist_filename_at_pos(pos)
  marks[slot] = {
    filename = filename,
    pos = pos,
  }
  save_marks()
  mp.osd_message(concat({ "Mark", slot, "set" }, " "))
end

local M = {}

for i = 0, 9 do
  M[concat({ "jump_to_mark_", i })] = function()
    jump_to_mark(i)
  end

  M[concat({ "set_mark_", i })] = function()
    set_mark(i)
  end
end

return M
