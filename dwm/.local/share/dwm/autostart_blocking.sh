#!/bin/sh

hsetroot -cover ~/.local/share/wallpaper/current

~/.local/share/dwm/scripts/status &
# If not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || ~/.local/share/wm/scripts/autolock &

~/.local/share/wm/scripts/sxhkd
# If not using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || compton -b
espanso restart

if [ -f ~/.local/share/dwm/autostart_blocking.local.sh ]
then
    ~/.local/share/dwm/autostart_blocking.local.sh
fi
