local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({ package.path, concat({ home, "lib/?.lua" }, "/") }, ";")

local control = require("control")
local marks = require("marks")

for i = 0, 9 do
  local jump_to_mark_i = concat({ "jump_to_mark_", i })

  mp.add_key_binding(tostring(i), jump_to_mark_i, function()
    marks[jump_to_mark_i]()
  end)

  local set_mark_i = concat({ "set_mark_", i })

  mp.add_key_binding(concat({ "Alt+", i }), set_mark_i, function()
    marks[set_mark_i]()
  end)
end

mp.add_key_binding("Ctrl+f", "playlist_go_to_start", function()
  control.playlist_go_to_start()
end)

mp.add_key_binding("Ctrl+l", "playlist_go_to_end", function()
  control.playlist_go_to_end()
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

mp.add_key_binding("TAB", "previous_position_play", function()
  control.previous_position_play()
end)

