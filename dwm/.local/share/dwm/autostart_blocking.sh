#!/bin/sh

hsetroot -cover ~/.local/share/wallpaper/current

~/.local/share/dwm/scripts/status &
# Don't run compton if using a virtual frame buffer
pgrep -f "Xvfb.*${DISPLAY}\b" || compton -b

if [ -f ~/.local/share/dwm/autostart_blocking.local.sh ]
then
    ~/.local/share/dwm/autostart_blocking.local.sh
fi
