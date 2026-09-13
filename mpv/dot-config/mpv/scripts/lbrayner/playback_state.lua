local function log(...)
  print("[playback_state]", ...)
end

local concat = table.concat
local playback_state = require("lbrayner/lib/playback_state")
local utils = require("lbrayner/lib/utils")

-- save only playback position
mp.set_property("watch-later-options", "start")

local function get_filename()
  return mp.get_property(concat({
    "playlist/", mp.get_property("playlist-pos"), "/filename"
  }))
end

local function update_state(property, value)
  log("Update state:", property, "changed to", value)

  if not utils.is_file_loaded() then
    log("Update state: no file loaded so far")
    playback_state.reset()
    return
  end

  local filename = get_filename()
  log("Update state: attempting to update playback state of", filename)
  playback_state.update(filename, property, value)
end

mp.observe_property("video-pan-x", "number", update_state)
mp.observe_property("video-pan-y", "number", update_state)
mp.observe_property("video-zoom", "number", update_state)

mp.register_event("file-loaded", function()
  local filename = get_filename()
  log("Attempting to restore playback state of", filename)
  playback_state.restore(filename)
end)
