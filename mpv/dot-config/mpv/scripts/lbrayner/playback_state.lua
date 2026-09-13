local function log(...)
  print("[playback_state]", ...)
end

local concat = table.concat
local previous
local playback_state = require("lbrayner/lib/playback_state")

mp.register_event("file-loaded", function()
  if previous then
    log("Saving ", previous)
    playback_state.save(previous)
  end

  local filename = mp.get_property(concat({
    "playlist/", mp.get_property("playlist-pos"), "/filename"
  }))

  previous = filename
  log("Set previous to:", filename)

  playback_state.restore(filename)
end)
