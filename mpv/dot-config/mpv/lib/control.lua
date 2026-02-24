local M = {}

function M.pause_watch_later()
  local is_paused = mp.get_property_native("pause")

  if not is_paused then
    mp.command("write-watch-later-config")
  end

  mp.set_property_native("pause", not is_paused)
end

function M.playlist_go_to_start()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.command("write-watch-later-config")
  mp.set_property_native("playlist-pos-1", 1) -- Go to playlist start
end

function M.playlist_go_to_end()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.command("write-watch-later-config")
  mp.set_property_native("playlist-pos-1", count) -- Go to playlist end
end

function M.playlist_next_watch_later()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.command("write-watch-later-config")

  local pos = mp.get_property_native("playlist-pos-1")

  if pos < count then
    mp.command("playlist-next")
  else
    mp.set_property_native("playlist-pos-1", 1) -- Go to start
  end
end

function M.playlist_previous_watch_later()
  local count = mp.get_property_native("playlist-count")

  if count == 1 then return end

  mp.command("write-watch-later-config")

  local pos = mp.get_property_native("playlist-pos-1")

  if pos > 1 then
    mp.command("playlist-prev")
  else
    mp.set_property_native("playlist-pos-1", count) -- Go to end
  end
end

return M
