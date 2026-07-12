local concat = table.concat

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

function string:endswith(suffix)
  return suffix == "" or self:sub(-#suffix) == suffix
end

mp.register_event("file-loaded", function()
  local path = mp.get_property_native("path")
  local pos = mp.get_property_native("playlist-pos-1")
  local filename = get_playlist_filename_at_pos(pos)
  print("path", path, "filename", filename, "endswith", path:endswith(filename:sub(3)))
end)
