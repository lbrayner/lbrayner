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

  for _, p in ipairs(M.get_properties()) do
    if state[p] and mp.get_property_number(p) ~= state[p] then
      mp.set_property_number(p, state[p])
      log("Restored", p, "to 0")
    end
  end

  log("Playback state restored for", filename)
end

function M.update(filename, property, value)
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  ) or {}

  local state = playback_state_by_filename[filename] or {}
  log("Update: property", property, "current", state[property], "value", value)

  if state[property] == value or not state and value == 0 then
    log("Sate will not be saved. No pan or zoom set for", filename)
    return
  end

  state[property] = value
  playback_state_by_filename[filename] = state

  mp.set_property_native(PLAYBACK_STATE_BY_FILENAME, playback_state_by_filename)
  log("Playback state saved for", filename)
end

return M
