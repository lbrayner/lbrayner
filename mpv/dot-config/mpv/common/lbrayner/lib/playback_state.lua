local function log(...)
  print("[lib/playback_state]", ...)
end

local PLAYBACK_STATE_BY_FILENAME = (
  "user-data/lbrayner/playback_state/playback_state_by_filename"
)

local M = {}
local concat = table.concat

function M.get_properties()
  return {
    "video-pan-x",
    "video-pan-y",
    "video-zoom",
  }
end

function M.reset()
  for _, p in ipairs(M.get_properties()) do
    if mp.get_property_number(p) ~= 0 then
      mp.set_property_number(p, 0)
      log("Set", p, "to 0")
    end
  end
end

function M.restore(filename)
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  ) or {}

  local state = playback_state_by_filename[filename]

  if not state then
    log("Playback state not set for", filename)

    M.reset()
    return
  end

  local pan_x = state.pan_x
  local pan_y = state.pan_y
  local zoom  = state.zoom

  mp.set_property_number("video-pan-x", pan_x)
  mp.set_property_number("video-pan-y", pan_y)
  mp.set_property_number("video-zoom", zoom)

  log("Restored pan_x", pan_x, "pan_y", pan_y, "zoom", zoom)
  log("Playback state restored for", filename)
end

function M.save(filename)
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  ) or {}

  local pan_x = mp.get_property_number("video-pan-x")
  local pan_y = mp.get_property_number("video-pan-y")
  local zoom  = mp.get_property_number("video-zoom")

  log("Got pan_x", pan_x, "pan_y", pan_y, "zoom", zoom)

  if pan_x == 0 and pan_y == 0 and zoom == 0 then
    log("Sate will not be saved. No pan or zoom set for", filename)
    return
  end

  playback_state_by_filename[filename] = { pan_x = pan_x, pan_y = pan_y, zoom  = zoom, }

  mp.set_property_native(PLAYBACK_STATE_BY_FILENAME, playback_state_by_filename)
  log("Playback state saved for", filename)
end

return M
