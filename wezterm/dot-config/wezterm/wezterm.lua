-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.term = "wezterm"

config.unix_domains = {
  { name = "unix" },
}
config.default_gui_startup_args = { "connect", "unix" }

wezterm.on("gui-attached", function(domain)
  for _, window in ipairs(wezterm.gui.gui_windows()) do
    window:maximize()
  end
end)

config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"

-- For example, changing the color scheme:
-- https://github.com/gfguthrie/wezterm-canonical-solarized
require("canonical_solarized").apply_to_config(config)
config.color_scheme = "Canonical Solarized Dark"
config.font = wezterm.font("IosevkaTerm Nerd Font")
config.font_size = 16
config.bold_brightens_ansi_colors = "No"

config.font_rules = {
  {
    intensity = "Bold",
    italic = false,
    font = wezterm.font({
      family = "IosevkaTerm Nerd Font",
      weight = "Bold",
    }),
  },
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font({
      family = "IosevkaTerm Nerd Font",
      weight = "Bold",
      style = "Italic",
    }),
  },
  {
    intensity = "Normal",
    italic = true,
    font = wezterm.font({
      family = "IosevkaTerm Nerd Font",
      style = "Italic",
    }),
  },
}

config.leader = {
  key = "q",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = "PageDown",
    mods = "CTRL",
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "PageUp",
    mods = "CTRL",
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "Tab",
    mods = "CTRL",
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "Tab",
    mods = "CTRL|SHIFT",
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "x",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({
      confirm = true,
    }),
  },
  {
    key = "q",
    mods = "LEADER",
    action = wezterm.action.ActivateLastTab,
  },
  {
    key = "n",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(-1),
  },
}

for i = 0, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i),
  })
end

wezterm.on("format-tab-title", function(tab)
  return string.format(
    " %d: %s ",
    tab.tab_index,
    tab.tab_title ~= "" and tab.tab_title or tab.active_pane.title
  )
end)

pcall(require, "workspaces")

return config
