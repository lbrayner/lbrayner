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
    ["video-pan-x"] = 0,
    ["video-pan-y"] = 0,
    ["video-zoom"] = 0,
    ["speed"] = 1,
  }
end

function M.restore(filename)
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  ) or {}

  local state = playback_state_by_filename[filename] or {}

  for p, d in pairs(M.get_properties()) do
    local value = state[p]

    if value then
      if mp.get_property_number(p) ~= value then
        mp.set_property_number(p, value)
        log("Restore: restored", p, "to", value)
      end
    else
      if mp.get_property_number(p) ~= d then
        mp.set_property_number(p, d)
        log("Restore: set", p, "to default", d)
      end
    end
  end
end

function M.update(filename, property, value)
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  ) or {}

  local state = playback_state_by_filename[filename] or {}
  local current = state[property]
  local default = M.get_properties()[property]
  log("Update:", property, "current", current, "value", value)

  if current == value or not current and value == default then
    log("Update: state of", property, "WILL NOT be updated for", filename)
    return
  end

  state[property] = value
  playback_state_by_filename[filename] = state

  mp.set_property_native(PLAYBACK_STATE_BY_FILENAME, playback_state_by_filename)
  log("Update: playback state update for", filename)
end

return M
