Set up MPV custom scripts:

```bash
ln -s ~/git/lbrayner/mpv/dot-config/mpv/scripts/ ~/.config/mpv/
```

Required environment variable:

```bash
export MPV_CONFIG_HOME=~/git/lbrayner/mpv/dot-config/mpv
```

# uosc

I'm currently using [uosc](https://github.com/tomasklaen/uosc), a "Feature-rich
minimalist proximity-based UI for MPV player."

Set up [custom uosc scripts](https://gitlab.com/lbrayner/uosc).

# json (required to load and set marks)

Download <https://github.com/rxi/json.lua/blob/master/json.lua> into
`~/.config/mpv/vendor/lib` and set up `MPV_VENDOR_HOME`:

```bash
export MPV_VENDOR_HOME=~/.config/mpv/vendor
```
