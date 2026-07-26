local function log(...)
  print("[playlist_index]", ...)
end

local playlist_index = require("lbrayner/lib/playlist_index")
local utils = require("lbrayner/lib/utils")

local playlist_count

mp.observe_property("playlist-count", "native", function(_, value)
  if not utils.is_file_loaded() then return end

  if not playlist_index.is_initialized() then
    log("Playlist Index is empty, nothing to do")
  elseif playlist_count and value < playlist_count then
    log("Playlist count went down, clearing Playlist Index...")
    playlist_index.clear()
  elseif playlist_count then
    log("Playlist count went up, updating Playlist Index...")
    playlist_index.get_updated_playlist_index(playlist_count + 1)
  end

  playlist_count = value
end)
