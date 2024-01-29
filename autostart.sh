#!/bin/sh

# Resolution monitor
xrandr --output Virtual1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output Virtual --off &
# Keyboard Layouti
setxkbmap latam &
# systray battery icon
cbatticon -u 5 &
# systray volume
volumeicon &
# Automount Devices
udiskie -t &
# Network
nm-applet &
