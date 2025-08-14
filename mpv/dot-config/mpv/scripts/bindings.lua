mp.add_key_binding("n", "playlist_next_watch_later", function()
  print("playlist_next_watch_later was called!")
  mp.command("write-watch-later-config")
  mp.command("playlist-next")
end)

mp.add_key_binding("p", "playlist_previous_watch_later", function()
  mp.command("write-watch-later-config")
  mp.command("playlist-prev")
end)

mp.add_key_binding("SPACE", "pause_watch_later", function()
  local is_paused = mp.get_property_native("pause")
  if not is_paused then
    mp.command("write-watch-later-config")
  end
  mp.set_property_native("pause", not is_paused)
end)
