local function log(...)
  print("[lib/marks]", ...)
end

local LIST = "user-data/lbrayner/marks/list"
local MARKS = "user-data/lbrayner/marks/marks"
local concat = table.concat
local control = require("lbrayner/lib/control")
local playlist_index = require("lbrayner/lib/playlist_index")
local utils = require("lbrayner/lib/utils")

local backup_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/marks"
local marks_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/marks"

local created_backup_dir, lazyloaded_marks, marks_path

local function get_backup_dir()
  if created_backup_dir then return backup_dir end

  os.execute(concat{ "test -d ", backup_dir, " || mkdir -p ", backup_dir })
  created_backup_dir = true
  return backup_dir
end

local function get_marks_path()
  if marks_path ~= nil then return marks_path end

  local ipc_name = utils.get_ipc_name()

  if not ipc_name then
    marks_path = false
    return
  end

  os.execute(concat{ "test -d ", marks_dir, " || mkdir -p ", marks_dir })
  marks_path = concat({ marks_dir, "/", ipc_name })
  os.execute(concat{ "test -f ", marks_path, " || touch ", marks_path })
  return marks_path
end

local function update_state(marks)
  local keys = {}

  for k in pairs(marks) do
    table.insert(keys, k)
  end

  table.sort(keys)

  local list = {}

  for _, k in ipairs(keys) do
    table.insert(list, { filename = marks[k].filename, slot = k })
  end

  mp.set_property_native(LIST, list)
  mp.set_property_native(MARKS, marks)
end

local function get_marks()
  local marks = mp.get_property_native(MARKS)

  if marks then
    log("Marks set, lazyloaded_marks", lazyloaded_marks)
    return marks
  end

  if not lazyloaded_marks then
    lazyloaded_marks = true
    local marks_path = get_marks_path()

    if marks_path then
      local json_encoded

      for line in io.lines(marks_path) do
        json_encoded = line
      end

      if json_encoded then
        marks = require("json").decode(json_encoded)
        log("Loaded Marks")
      end
    end
  end

  marks = marks or {}
  update_state(marks)

  return marks
end

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

local function jump_to_mark(slot)
  if not get_marks()[slot] then
    mp.osd_message(concat({ "Mark", slot, "no set" }, " "))
    return
  end

  local mark = get_marks()[slot]
  local item = playlist_index.get_extended_playlist_items_by_filename(mark.filename)[1]

  if not item or item.filename ~= mark.filename then
    mp.osd_message(concat({ "Mark", slot, "invalid" }, " "))
    return
  end

  control.playlist_jump_to_position(item.pos)
end

local function write_json(t, path)
  if next(t) == nil then return end

  local handle = io.open(path, "w")
  handle:write(concat({ require("json").encode(t), "\n" }))
  handle:close()
end

local function backup_marks(marks)
  local ipc_name = utils.get_ipc_name()

  if not ipc_name then return end

  local backup_dir = get_backup_dir()
  local tmpname = os.tmpname():match("([%w_]+)$")
  local backup_path = concat({ backup_dir, "/", ipc_name, "_", tmpname })

  write_json(marks, backup_path)
end

local function persist_marks(marks)
  local marks_path = get_marks_path()

  if not marks_path then return end

  write_json(marks, marks_path)
end

local function set_mark(slot)
  local pos = mp.get_property_native("playlist-pos-1")
  local filename = get_playlist_filename_at_pos(pos)

  local marks = get_marks()
  local mark = marks[slot]

  if not mark or mark.filename ~= filename then
    if mark then
      backup_marks(marks)
    end

    marks[slot] = {
      filename = filename,
    }

    update_state(marks)
    persist_marks(marks)
  end

  mp.osd_message(concat({ "Mark", slot, "set" }, " "))
end

local M = {}

for i = 0, 9 do
  i = tostring(i)

  M[concat({ "jump_to_mark_", i })] = function()
    jump_to_mark(i)
  end

  M[concat({ "set_mark_", i })] = function()
    set_mark(i)
  end
end

function M.load()
  get_marks()
end

return M
