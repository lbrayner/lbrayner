#!/bin/sh

hsetroot -cover ~/.local/share/wallpaper/current

status &
# If not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || autolock &
~/.local/share/wm/scripts/sxhkd

# If not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || compton -b
espanso restart

[ -x ~/.local/share/dwm/autostart_blocking.local.sh ] && \
    ~/.local/share/dwm/autostart_blocking.local.sh
