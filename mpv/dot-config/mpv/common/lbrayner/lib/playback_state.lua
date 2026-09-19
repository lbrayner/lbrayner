local function log(...)
  print("[lib/playback_state]", ...)
end

local PLAYBACK_STATE_BY_FILENAME = (
  "user-data/lbrayner/playback_state/playback_state_by_filename"
)

local concat = table.concat
local utils = require("lbrayner/lib/utils")

local dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/playback_state"
local playback_state_path, save_timer

local function get_playback_state_path()
  if playback_state_path ~= nil then return playback_state_path end

  local ipc_name = utils.get_ipc_name()

  if not ipc_name then
    playback_state_path = false
    return playback_state_path
  end

  os.execute(concat{ "test -d ", dir, " || mkdir -p ", dir })
  playback_state_path = concat({ dir, "/", ipc_name })
  os.execute(concat{ "test -f ", playback_state_path, " || touch ", playback_state_path })
  return playback_state_path
end

local function persist(playback_state_by_filename)
  if next(playback_state_by_filename) == nil then
    log("Persist: state is empty")
  end

  if save_timer then
    log("Persist: killed timer")
    save_timer:kill()
  end

  local path = get_playback_state_path()

  if not path then
    log(concat({
      "[ERROR] Failed to persist playback state: ",
      "could not obtain playbatck state file path",
    }))

    return
  end

  log("Persist: adding timeout...")

  save_timer = mp.add_timeout(5, function()
    save_timer = nil

    log("Persist: persisting state...")

    local path = get_playback_state_path()

    local handle = io.open(path, "w")
    handle:write(concat({ require("json").encode(playback_state_by_filename), "\n" }))
    handle:close()

    log("Persist: persisted state")
  end)
end

local M = {}

local default_volume = mp.get_property_number("volume")

function M.get_properties()
  return {
    ["video-pan-x"] = 0,
    ["video-pan-y"] = 0,
    ["video-zoom"] = 0,
    ["volume"] = default_volume,
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

  state[property] = value ~= default and value or nil
  playback_state_by_filename[filename] = next(state) ~= nil and state or nil

  mp.set_property_native(PLAYBACK_STATE_BY_FILENAME, playback_state_by_filename)
  log("Update: playback state update for", filename)

  log("Update: attempting to persist playback state")
  persist(playback_state_by_filename)
end

return M
