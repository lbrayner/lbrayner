local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

local vendor = os.getenv("MPV_VENDOR_HOME")

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
local backup_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/backup/marks"
local marks_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/marks"

local created_backup_dir, lazyloaded_marks, ipc_name, marks_path
local marks = {}

local function get_ipc_name()
  if ipc_name ~= nil then return ipc_name end

  ipc_name = mp.get_property("input-ipc-server"):match("([%w_]+)$")

  if not ipc_name then
    ipc_name = false
  end

  return ipc_name
end

local function get_backup_dir()
  if created_backup_dir then return backup_dir end

  os.execute(concat{ "test -d ", backup_dir, " || mkdir -p ", backup_dir })
  created_backup_dir = true
  return backup_dir
end

local function get_marks_path()
  if marks_path ~= nil then return marks_path end

  local ipc_name = get_ipc_name()

  if not ipc_name then
    marks_path = false
    return
  end

  os.execute(concat{ "test -d ", marks_dir, " || mkdir -p ", marks_dir })
  marks_path = concat({ marks_dir, "/", ipc_name })
  os.execute(concat{ "test -f ", marks_path, " || touch ", marks_path })
  return marks_path
end

local function get_marks()
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
      end
    end
  end

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
  local filename = get_playlist_filename_at_pos(mark.pos)

  if filename ~= mark.filename then
    mp.osd_message(concat({ "Mark", slot, "invalid" }, " "))
    return
  end

  control.playlist_jump_to_position(mark.pos)
end

local function write_json(t, path)
  if next(t) == nil then return end

  local handle = io.open(path, "w")
  handle:write(concat({ require("json").encode(t), "\n" }))
  handle:close()
end

local function backup_marks()
  local ipc_name = get_ipc_name()

  if not ipc_name then return end

  local backup_dir = get_backup_dir()
  local tmpname = os.tmpname():match("([%w_]+)$")
  local backup_path = concat({ backup_dir, "/", tmpname, "_", ipc_name })

  write_json(get_marks(), backup_path)
end

local function save_marks()
  local marks_path = get_marks_path()

  if not marks_path then return end

  write_json(get_marks(), marks_path)
end

local function set_mark(slot)
  local pos = mp.get_property_native("playlist-pos-1")
  local filename = get_playlist_filename_at_pos(pos)

  local mark = get_marks()[slot]

  if not mark or mark.filename ~= filename or mark.pos ~= pos then
    if mark then
      backup_marks()
    end

    get_marks()[slot] = {
      filename = filename,
      pos = pos,
    }

    save_marks()
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

local function revalidate_marks()
  local invalid_marks = {}

  for _, mark in pairs(get_marks()) do
    local filename = get_playlist_filename_at_pos(mark.pos)
    if filename ~= mark.filename then
      invalid_marks[mark.filename] = mark
    end
  end

  local count = 0
  for _ in pairs(invalid_marks) do count = count + 1 end

  print(count, "invalid mark(s)")

  local function iterate_playlist()
    for pos, item in ipairs(mp.get_property_native("playlist")) do
      if next(invalid_marks) == nil then
        print("Short-circuited iterate_playlist in revalidate_marks")
        return
      end

      local mark = invalid_marks[item.filename]

      if mark then
        mark.pos = pos
        invalid_marks[mark.filename] = nil
        print("Revalidated", mark.filename)
      end
    end
  end

  iterate_playlist()
  save_marks()
end

function M.handle_message(message)
  if message == "revalidate_marks" then
    revalidate_marks()
  end
end

local ass_start = mp.get_property_osd("osd-ass-cc/0")
local ass_stop = mp.get_property_osd("osd-ass-cc/1")
local duration, timeout = 20

function M.show_marks()
  if timeout then
    if os.time() < timeout then
      timeout = nil
      mp.osd_message("", 0)
      return
    end
  end

  local keys = {}
  local marks = get_marks()

  if not marks then
    mp.osd_message("No marks set")
    return
  end

  for k in pairs(marks) do
    table.insert(keys, k)
  end

  table.sort(keys)

  local lines = {}
  local pos = mp.get_property_native("playlist-pos-1")
  local filename = get_playlist_filename_at_pos(pos)

  for _, k in ipairs(keys) do
    local color, reset = "", ""
    local mark = marks[k]

    if mark.pos == pos and mark.filename == filename then
      color = "{\\c&HFF0000&}"
      reset = "{\\c&HFFFFFF&}"
    end

    table.insert(lines, concat({ color, k, " → ", mark.filename, reset }))
  end

  timeout = os.time() + duration
  mp.osd_message(concat({ ass_start, "{\\fs12}", concat(lines, "\n"), ass_stop }), duration)
end

return M
