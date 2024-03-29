#!/bin/sh

# Wallpaper
hsetroot -cover ~/.local/share/wallpaper/current

# Dwm status
dwmblocks &

# Autolock display if not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || xautolock -time 10 -locker slock &

# sxhkd
~/.local/share/wm/scripts/sxhkd

# Run compositor if not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || picom -b

[ -x ~/.local/share/dwm/autostart_blocking.local.sh ] && \
    ~/.local/share/dwm/autostart_blocking.local.sh
