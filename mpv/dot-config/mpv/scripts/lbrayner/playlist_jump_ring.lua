local function log(...)
  print("[playlist_jump_ring]", ...)
end

local concat = table.concat
local playlist_jump_ring = require("lbrayner/lib/playlist_jump_ring")

mp.register_event("file-loaded", function()
  local filename = mp.get_property(concat({
    "playlist/", mp.get_property("playlist-pos"), "/filename"
  }))

  log("Adding to jump ring:", filename)
  playlist_jump_ring.add(filename)
end)
