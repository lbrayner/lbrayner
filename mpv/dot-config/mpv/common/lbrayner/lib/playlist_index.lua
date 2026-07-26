local function log(...)
  print("[lib/playlist_index]", ...)
end

local EXTENDED_PLAYLIST_ITEMS_BY_FILENAME = (
  "user-data/lbrayner/playlist_index/extended_playlist_items_by_filename"
)
local M = {}

function M.clear()
  mp.set_property_native(EXTENDED_PLAYLIST_ITEMS_BY_FILENAME, nil)
  log("Playlist Index cleared")
end

function M.handle_message(message)
  if message == "playlist_index_clear" then
    M.clear()
  end
end

function M.get_extended_playlist_items_by_filename(filename)
  local extended_playlist_items_by_filename = mp.get_property_native(
    EXTENDED_PLAYLIST_ITEMS_BY_FILENAME
  )

  if extended_playlist_items_by_filename then
    return extended_playlist_items_by_filename[filename] or {}
  end

  extended_playlist_items_by_filename = {}

  M.index_and_extend_playlist_items(
    extended_playlist_items_by_filename, mp.get_property_native("playlist")
  )

  mp.set_property_native(
    EXTENDED_PLAYLIST_ITEMS_BY_FILENAME,
    extended_playlist_items_by_filename
  )

  return extended_playlist_items_by_filename[filename] or {}
end

function M.index_and_extend_playlist_items(extended_playlist_items_by_filename, items)
  for i, item in ipairs(items) do
    if not extended_playlist_items_by_filename[item.filename] then
      extended_playlist_items_by_filename[item.filename] = {}
    end

    item.pos = i
    table.insert(extended_playlist_items_by_filename[item.filename], item)
  end

  return extended_playlist_items_by_filename
end

return M
