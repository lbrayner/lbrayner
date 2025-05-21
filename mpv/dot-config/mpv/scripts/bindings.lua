mp.add_key_binding("n", "playlist_next_watch_later", function()
  mp.command("write-watch-later-config")
  mp.command("playlist-next")
end)

mp.add_key_binding("p", "playlist_previous_watch_later", function()
  mp.command("write-watch-later-config")
  mp.command("playlist-prev")
end)

mp.add_key_binding("SPACE", "pause_watch_later", function()
  mp.command("write-watch-later-config")
  local cycle = not mp.get_property_native("pause")
  mp.set_property_native("pause", cycle)
end)

