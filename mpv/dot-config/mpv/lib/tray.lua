local concat = table.concat

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

local M = {}
local tray = {}

function M.add()
  local filename = get_playlist_filename_at_pos(mp.get_property_native("playlist-pos-1"))

  if tray[filename] then
    print(filename, "already on tray")
    return
  end

  tray[filename] = true
  mp.set_property_native("user-data/lbrayner/tray/tray", tray)
  print("Added", filename, "to tray")
end

return M
