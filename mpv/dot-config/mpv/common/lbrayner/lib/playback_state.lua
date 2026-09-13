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
    log("Restore: playback state not set for", filename)

    M.reset()
    return
  end

  for _, p in ipairs(M.get_properties()) do
    local value = state[p]

    if value then
      mp.set_property_number(p, value)
      log("Restore: restored", p, "to", value)
    end
  end

  log("Restore: playback state restored for", filename)
end

function M.update(filename, property, value)
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  ) or {}

  local state = playback_state_by_filename[filename] or {}
  local current = state[property]
  log("Update: property", property, "current", current, "value", value)

  if current == value or not current and value == 0 then
    log("Update: state will not be updated for", filename)
    return
  end

  state[property] = value
  playback_state_by_filename[filename] = state

  mp.set_property_native(PLAYBACK_STATE_BY_FILENAME, playback_state_by_filename)
  log("Update: playback state update for", filename)
end

return M
