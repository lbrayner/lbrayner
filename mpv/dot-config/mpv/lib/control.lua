local M = {}

function M.pause_watch_later()
  local is_paused = mp.get_property_native("pause")

  if not is_paused then
    mp.command("write-watch-later-config")
  end

  mp.set_property_native("pause", not is_paused)
end

function M.playlist_next_watch_later()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.command("write-watch-later-config")

  local pos = mp.get_property_native("playlist-pos")

  if (pos + 1) < count then
    mp.command("playlist-next")
  else
    mp.commandv("playlist-play-index", 0) -- Go to start
  end
end

function M.playlist_previous_watch_later()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.command("write-watch-later-config")

  local pos = mp.get_property_native("playlist-pos")

  if pos > 0 then
    mp.command("playlist-prev")
  else
    mp.commandv("playlist-play-index", (count - 1)) -- Go to end
  end
end

return M
