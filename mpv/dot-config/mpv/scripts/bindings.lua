mp.add_key_binding("n", "playlist_next_watch_later", function()
  mp.command("write-watch-later-config")
  mp.command("playlist-next")
end)

mp.add_key_binding("p", "playlist_previous_watch_later", function()
  mp.command("write-watch-later-config")
  mp.command("playlist-prev")
end)
