local function log(message)
  print("[main]", message)
end

local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  log("MPV_CONFIG_HOME is required.")
  return
end

local vendor = os.getenv("MPV_VENDOR_HOME")

if not vendor or vendor == "" then
  log("MPV_VENDOR_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({
  package.path,
  concat({ home, "common/?.lua" }, "/"),
  concat({ home, "common/?/init.lua" }, "/"),
  concat({ vendor, "lib/?.lua" }, "/")
}, ";")

require("bindings")
require("message_handler")
require("playlist_autosave")
require("playlist_jump_ring")
require("startup")
