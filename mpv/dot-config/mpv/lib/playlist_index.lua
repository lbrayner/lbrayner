local M = {}

function M.clear()
  mp.set_property_native(
    "user-data/lbrayner/playlist_index/extended_playlist_items_by_filename",
    nil
  )
  print("Playlist Index cleared")
end

function M.handle_message(message)
  if message == "playlist_index_clear" then
    M.clear()
  end
end

function M.get_extended_playlist_items_by_filename(filename)
  local extended_playlist_items_by_filename = mp.get_property_native(
    "user-data/lbrayner/playlist_index/extended_playlist_items_by_filename"
  )

  if extended_playlist_items_by_filename then
    return extended_playlist_items_by_filename[filename] or {}
  end

  extended_playlist_items_by_filename = {}

  for i, item in ipairs(mp.get_property_native("playlist")) do
    if not extended_playlist_items_by_filename[item.filename] then
      extended_playlist_items_by_filename[item.filename] = {}
    end

    item.pos = i
    table.insert(extended_playlist_items_by_filename[item.filename], item)
  end

  mp.set_property_native(
    "user-data/lbrayner/playlist_index/extended_playlist_items_by_filename",
    extended_playlist_items_by_filename
  )

  return extended_playlist_items_by_filename[filename] or {}
end

return M
