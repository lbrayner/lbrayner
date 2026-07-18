local concat = table.concat

local function get_playlist_filename_at_pos(pos)
  return mp.get_property(concat({ "playlist/", pos - 1, "/filename" }))
end

function string:endswith(suffix)
  return suffix == "" or self:sub(-#suffix) == suffix
end

function string:startswith(prefix)
    return self:sub(1, #prefix) == prefix
end

local recent_files
local recent_files_dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/recent_files"

mp.register_event("file-loaded", function()
  local path = mp.get_property_native("path")
  local pos = mp.get_property_native("playlist-pos-1")
  local filename = get_playlist_filename_at_pos(pos)
  local compare = filename:startswith("./") and filename:sub(3) or filename

  print("path", path, "filename", filename, "endswith", path:endswith(filename:sub(3)))

  -- if not recent_files then
  --   os.execute(concat{ "test -d ", recent_files_dir, " || mkdir -p ", recent_files_dir })
  --
  --   local tmpname = os.tmpname():match("([^/\\]+)$")
  --   recent_files = concat({ recent_files_dir, "/", "recent_files_", tmpname, ".m3u" })
  -- end
  --
  -- local file = io.open(recent_files, "a")
  -- file:write(concat({ filename, "\n" }))
  -- file:close()
  -- print("Append to", playlist_name)
end)
