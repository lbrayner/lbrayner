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

local M = {}

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

local function get_playback_state_by_filename()
  local playback_state_by_filename = mp.get_property_native(
    PLAYBACK_STATE_BY_FILENAME
  )

  if playback_state_by_filename then
    return playback_state_by_filename
  end

  local path = get_playback_state_path()
  playback_state_by_filename = {}

  if path then
    local json_encoded

    for line in io.lines(path) do
      json_encoded = line
    end

    if json_encoded then
      playback_state_by_filename = require("json").decode(json_encoded)
      log("Decoded json")
    end
  else
    log(concat({
      "[ERROR] Failed to read playback state from file: ",
      "could not obtain playbatck state file path",
    }))
  end

  if next(playback_state_by_filename) ~= nil then
    -- Setting native property to an empty first time table messes up the type
    -- (should be a Map, Dictionary)
    mp.set_property_native(PLAYBACK_STATE_BY_FILENAME, playback_state_by_filename)
  end

  return playback_state_by_filename
end

local function schedule_persist(playback_state_by_filename)
  if not get_playback_state_path() then
    log(concat({
      "Schedule: could not obtain playbatck state file path, ",
      "will not schedule persist",
    }))

    return
  end

  if save_timer then
    log("Schedule: killed timer")
    save_timer:kill()
  end

  log("Schedule: adding timeout...")

  save_timer = mp.add_timeout(5, function()
    save_timer = nil
    M.persist(playback_state_by_filename)
  end)
end

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

function M.persist(playback_state_by_filename)
  local path = get_playback_state_path()

  if not path then
    log(concat({
      "[ERROR] Failed to persist playback state: ",
      "could not obtain playback state file path",
    }))

    return
  end

  log("Persist: persisting state...")

  if not playback_state_by_filename then
    playback_state_by_filename = get_playback_state_by_filename()
  end

  if next(playback_state_by_filename) == nil then
    log("Persist: state is empty")
  end

  local handle = io.open(path, "w")
  handle:write(concat({ require("json").encode(playback_state_by_filename), "\n" }))
  handle:close()

  log("Persist: persisted state")
end

function M.restore(filename)
  local playback_state_by_filename = get_playback_state_by_filename()
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
  local playback_state_by_filename = get_playback_state_by_filename()
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
  log("Update: playback state updated for", filename)

  schedule_persist(playback_state_by_filename)
end

return M
