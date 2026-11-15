-- Pull in the wezterm API
local wezterm = require("wezterm")

local names = {
  "Home",
  "Queries",
  "S2",
  "S3",
  "S4",
  "S5",
  "Code",
  "Clojure",
  "JVM",
  "S9",
}

wezterm.on("mux-startup", function()
  local tab, pane, window = wezterm.mux.spawn_window({
    workspace = "development",
  })

  tab:set_title(names[1])

  for i = 2, #names do
    local new_tab = window:spawn_tab({})
    new_tab:set_title(names[i])
  end
end)
