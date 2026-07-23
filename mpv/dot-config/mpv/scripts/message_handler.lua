local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({ package.path, concat({ home, "lib/?.lua" }, "/") }, ";")

local playlist_index = require("playlist_index")

mp.register_script_message("playlist_index", function(message)
  playlist_index.handle_message(message)
end)
