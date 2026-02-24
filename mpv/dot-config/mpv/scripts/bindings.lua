local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({ package.path, concat({ home, "lib/?.lua" }, "/") }, ";")

local control = require("control")

mp.add_key_binding("Ctrl+f", "playlist_go_to_start", function()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.set_property_native("playlist-pos-1", 1) -- Go to playlist start
end)

mp.add_key_binding("Ctrl+l", "playlist_go_to_end", function()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.set_property_native("playlist-pos-1", count) -- Go to playlist end
end)

mp.add_key_binding("n", "playlist_next_watch_later", function()
  control.playlist_next_watch_later()
end)

mp.add_key_binding("p", "playlist_previous_watch_later", function()
  control.playlist_previous_watch_later()
end)

mp.add_key_binding("SPACE", "pause_watch_later", function()
  control.pause_watch_later()
end)
