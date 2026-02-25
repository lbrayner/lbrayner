local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({ package.path, concat({ home, "lib/?.lua" }, "/") }, ";")

local control = require("control")
local marks_backup_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/marks"
local marks_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/marks"

local marks = {}

local function jump_to_mark(slot)
  if not marks[slot] then
    mp.osd_message(concat({ "Mark", slot, "no set" }, " "))
    return
  end
  control.playlist_jump_to_position(marks[slot])
end

local function set_mark(slot)
  local pos = mp.get_property_native("playlist-pos-1")
  marks[slot] = pos
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
