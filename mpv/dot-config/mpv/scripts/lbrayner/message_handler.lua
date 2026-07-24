local playlist_index = require("lbrayner/lib/playlist_index")

mp.register_script_message("playlist_index", function(message)
  playlist_index.handle_message(message)
end)
