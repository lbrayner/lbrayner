local function log(...)
  print("[playlist_jump_ring]", ...)
end

local concat = table.concat
local playlist_jump_ring = require("lbrayner/lib/playlist_jump_ring")
local utils = require("lbrayner/lib/utils")

mp.register_event("file-loaded", function()
  if not utils.is_file_loaded() then return end

  local filename = mp.get_property(concat({
    "playlist/", mp.get_property("playlist-pos"), "/filename"
  }))

  log("Adding to jump ring:", filename)
  playlist_jump_ring.add(filename)
end)
