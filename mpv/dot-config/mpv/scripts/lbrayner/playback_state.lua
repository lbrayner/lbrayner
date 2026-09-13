local function log(...)
  print("[playback_state]", ...)
end

local concat = table.concat
local playback_state = require("lbrayner/lib/playback_state")
local utils = require("lbrayner/lib/utils")

local function get_filename()
  return mp.get_property(concat({
    "playlist/", mp.get_property("playlist-pos"), "/filename"
  }))
end

local function save_state(property, value)
  log("Sate of", property, "changed to", value)

  if not utils.is_file_loaded() then
    log("No file loaded so far, nothing to do")
    return
  end

  local filename = get_filename()
  log("Attempting to save playback state of", filename)
  playback_state.save(filename)
end

mp.observe_property("video-pan-x", "number", save_state)
mp.observe_property("video-pan-y", "number", save_state)
mp.observe_property("video-zoom", "number", save_state)

mp.register_event("file-loaded", function()
  local filename = get_filename()
  log("Attempting to restore playback state of", filename)
  playback_state.restore(filename)
end)
