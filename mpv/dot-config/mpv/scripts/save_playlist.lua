local concat = table.concat
local file_loaded, file_loaded_cb

file_loaded_cb = function()
  print("file-loaded triggered")
  if not file_loaded then
    file_loaded = true
    mp.unregister_event(file_loaded_cb)
  end
end

mp.register_event("file-loaded", file_loaded_cb)

local initial_size

mp.observe_property('playlist-count', 'native', function(name, value)
  -- value 1 is always triggered
  -- if value == 1 then
  --   return
  -- end
  if not file_loaded then return end

  -- if not initial_size then
  --   initial_size = value
  --   return
  -- end

  -- Perform your action here when the playlist changes
  print("Playlist changed:", name, value)
  -- Add your custom logic here
  local dir = "/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/playlist-backup"
  -- os.execute(concat{ "test -d ", dir, " || mkdir -p ", dir })
  -- local name = os.execute(concat({ "mktemp -u -p ", dir }))
  -- print("name", name)

  -- local file = io.open("/var/tmp/9572cf67-b586-4c68-a7da-7cb904b396b3/playlist-backup", "w")
  -- local file = io.tmpfile()
  name = os.tmpname()
  local file = io.open(name, "w")

  for _, item in ipairs(mp.get_property_native("playlist")) do
    print("wrote", '"'.. item.filename ..'"', "to playlist", "file", name)
    file:write(concat({ item.filename, "\n" }))
  end

  file:close()
  os.execute(concat({ "mv", name, dir }, " "))
end)
