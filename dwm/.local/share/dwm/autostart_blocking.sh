#!/bin/sh

hsetroot -cover ~/.local/share/wallpaper/current

~/.local/share/dwm/scripts/status &
# Don't run compton if using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || compton -b
