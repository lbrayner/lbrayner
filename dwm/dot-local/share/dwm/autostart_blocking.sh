#!/bin/sh

hsetroot -cover ~/.local/share/wallpaper/current

# Dwm status
~/.local/share/dwm/scripts/dwm_status &
# Autolock display if not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" ||  ~/.local/share/wm/scripts/autolock &
~/.local/share/wm/scripts/sxhkd

# Run compositor if not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || compton -b

[ -x ~/.local/share/dwm/autostart_blocking.local.sh ] && \
    ~/.local/share/dwm/autostart_blocking.local.sh
