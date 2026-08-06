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

  extended_playlist_items_by_filename = M.get_updated_playlist_index(
  ).extended_playlist_items_by_filename

  return extended_playlist_items_by_filename[filename] or {}
end

function M.get_updated_playlist_index(start)
  start = start or 1
  assert(type(start) == "number", "'start' must be a number")

  if not M.is_initialized() then
    log("Not initialized, start", start)
    start = 1
  end

  local extended_playlist_items_by_filename = mp.get_property_native(
    EXTENDED_PLAYLIST_ITEMS_BY_FILENAME
  ) or {}
  local playlist = mp.get_property_native("playlist")

  log("Indexing playlist from position", start)

  for i = start, #playlist do
    local item = playlist[i]
    local items = extended_playlist_items_by_filename[item.filename]

    if not items then
      items = {}
      extended_playlist_items_by_filename[item.filename] = items
    end

    item.pos = i
    table.insert(items, item)
  end

  mp.set_property_native(
    EXTENDED_PLAYLIST_ITEMS_BY_FILENAME,
    extended_playlist_items_by_filename
  )

  return { extended_playlist_items_by_filename = extended_playlist_items_by_filename }
end

function M.is_initialized()
  return mp.get_property_native(
    EXTENDED_PLAYLIST_ITEMS_BY_FILENAME
  )
end

return M
