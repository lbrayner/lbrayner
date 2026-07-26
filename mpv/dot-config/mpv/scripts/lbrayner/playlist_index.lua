local function log(...)
  print("[playlist_index]", ...)
end

local playlist_index = require("lbrayner/lib/playlist_index")
local utils = require("lbrayner/lib/utils")

local EXTENDED_PLAYLIST_ITEMS_BY_FILENAME = (
  "user-data/lbrayner/playlist_index/extended_playlist_items_by_filename"
)
local playlist_count

mp.observe_property("playlist-count", "native", function(_, value)
  if not utils.is_file_loaded() then return end

  local extended_playlist_items_by_filename = mp.get_property_native(
    EXTENDED_PLAYLIST_ITEMS_BY_FILENAME
  )

  if not extended_playlist_items_by_filename then
    log("Playlist Index is empty, nothing to do")
  elseif playlist_count and value < playlist_count then
    log("Playlist count went down, clearing Playlist Index...")
    playlist_index.clear()
  elseif playlist_count then
    log("Playlist count went up, updating Playlist Index...")

    local playlist = mp.get_property_native("playlist")

    for i = playlist_count + 1, value do
      playlist_index.index_and_extend_playlist_item(
        extended_playlist_items_by_filename, playlist[i], { pos = i }
      )
    end

    mp.set_property_native(
      EXTENDED_PLAYLIST_ITEMS_BY_FILENAME,
      extended_playlist_items_by_filename
    )
  end

  playlist_count = value
end)
