# WezTerm: unix domain and site workspaces

WezTerm runs against a long-lived multiplexer (mux) server. The server builds
a named set of tabs for each site once, and the GUI just attaches to it.
Closing the window leaves the tabs and shells alive.

## How it fits together

```
systemd user service
  -> wezterm-mux-server        loads wezterm.lua, runs "mux-startup"
       -> creates one or more workspaces with named tabs (per site)

launcher / "wezterm connect unix"
  -> GUI attaches to the same server and shows that workspace
```

- The server loads the config **once, when it starts**. Editing the config
  has no effect on a running server until it is restarted.
- The `mux-startup` handler runs **only when the server starts**, so
  reconnecting a GUI never creates duplicate tabs.

## Layout

```
~/.config/wezterm/wezterm.lua   shared config (domain, search path, loader)
~/.wezterm  ->  <repo>/wezterm/dot-wezterm    (symlink, per site)
    site/main.lua               site code (e.g. font size, workspace and tab names)
```

Each site has its own dotfiles repo containing
`wezterm/dot-config/wezterm/site/main.lua`. The shared config loads
`site.main`, so every machine gets the tabs that belong to its site.

Create the link with `-n` so it never nests inside an existing directory:

```bash
ln -sfn ~/git/<repo>/wezterm/dot-wezterm ~/.wezterm
```

Without `-n`, if `~/.wezterm` already exists as a directory, `ln` creates the
link *inside* it (`~/.wezterm/wezterm`) and `require` silently fails.

## Shared config (`wezterm.lua`)

### Unix domain

```lua
config.unix_domains = {
  { name = "unix" },
}
config.default_gui_startup_args = { "connect", "unix" }
```

- `unix_domains` defines the server and its socket.
- `default_gui_startup_args` makes a plain `wezterm` behave like
  `wezterm connect unix`. It applies only when no subcommand is given.

### Making `~/.wezterm` searchable

`~/.wezterm` was not on Lua's search path in this setup, so it is added
explicitly:

```lua
local concat = table.concat
local home = wezterm.home_dir

package.path = concat({
  package.path,
  concat({ home, ".wezterm/?.lua" }, "/"),
  concat({ home, ".wezterm/?/init.lua" }, "/"),
}, ";")
```

### Loading the site module

```lua
do
  local ok, site = pcall(require, "site.main")
  if ok and type(site) == "function" then site(config) end
end
```

## Site module (`site/main.lua`)

```lua
local wezterm = require("wezterm")
local mux = wezterm.mux

local names = {
  "Home",
  "Queries",
  "WS",
}

wezterm.on("mux-startup", function()
  local tab, _, window = mux.spawn_window({
    workspace = "development",
  })

  tab:set_title(names[1])

  for i = 2, #names do
    local new_tab = window:spawn_tab({})
    new_tab:set_title(names[i])
  end
end)
```

Edit `names` to change the tabs for a site. The workspace name here must
match `config.default_workspace`.

## systemd user service

`~/.config/systemd/user/wezterm-mux.service`:

```ini
[Unit]
Description=WezTerm multiplexer server

[Service]
Type=simple
ExecStart=/usr/bin/wezterm-mux-server
Restart=no

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now wezterm-mux.service
```

- Do not pass `--daemonize`. With `Type=simple`, systemd must see the
  server stay in the foreground.
- `Restart=no` means a crashed server stays down. Use `Restart=on-failure`
  if systemd should bring it back.
- The server runs with systemd's user environment, not the shell's. Set
  anything a module needs with `Environment=` lines in the unit.

## Launcher

`wezterm start ...` ignores `default_gui_startup_args` and opens a separate
standalone GUI. Use a desktop file that connects to the server:

```bash
cp /usr/share/applications/org.wezfurlong.wezterm.desktop \
   ~/.local/share/applications/
```

Keep the same file name, and set in the copy:

```
Exec=wezterm
```

A user copy with the same name replaces the system entry, so the launcher
shows one WezTerm.

## Daily use

| Task                         | Command                                   |
| ---------------------------- | ----------------------------------------- |
| Rebuild tabs / reload config | `systemctl --user restart wezterm-mux`    |
| Server status                | `systemctl --user status wezterm-mux`     |
| Server log                   | `journalctl --user -u wezterm-mux -e`     |
| List windows, tabs, panes    | `wezterm cli list`                        |
| List attached GUI clients    | `wezterm cli list-clients`                |

Restarting the service closes every tab and shell in the server.

## Troubleshooting

- **Nothing changed after editing the config.** The server keeps the config
  it loaded at start. Restart the service.
- **Tabs missing or `site.main` not loading.** Check the logged error, then
  `ls -l ~/.wezterm/site/main.lua`. A symlink nested inside `~/.wezterm`
  is the usual cause.
- **Where logs go.**
  - Debug overlay: `Ctrl` + `Shift` + `L` (GUI process only).
  - Log files: `$XDG_RUNTIME_DIR/wezterm/` (one for the GUI, one for the
    server).
  - The server also logs to the journal (command above).
  - Errors inside the `mux-startup` handler appear only in the server's
    log, not in the GUI's overlay.
- **Connection refused or EOF errors.** Usually a stale or stuck server.
  Stop it, then start it again through the service.
- **Window will not maximize on COSMIC.** Maximize is a request, and the
  compositor may ignore it, for example when the window is tiled.
