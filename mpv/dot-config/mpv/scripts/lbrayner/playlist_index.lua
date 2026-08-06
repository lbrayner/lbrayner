local function log(...)
  print("[playlist_index]", ...)
end

local playlist_index = require("lbrayner/lib/playlist_index")
local utils = require("lbrayner/lib/utils")

local playlist_count

mp.observe_property("playlist-count", "native", function(_, value)
  if not utils.is_file_loaded() then
    playlist_count = value
    log("No file loaded so far, set playlist_count to", value)
    return
  end

  if not playlist_index.is_initialized() then
    log("Playlist Index is not initialized, nothing to do")
  elseif playlist_count and value < playlist_count then
    log(
      "Playlist count went down, clearing Playlist Index: playlist_count",
      playlist_count, "value", value
    )
    playlist_index.clear()
  elseif playlist_count then
    log(
      "Playlist count went up, updating Playlist Index: playlist_count",
      playlist_count, "value", value
    )
    playlist_index.get_updated_playlist_index(playlist_count + 1)
  end

  playlist_count = value
end)
