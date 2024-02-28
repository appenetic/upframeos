#!/bin/sh
xset -dpms # disable DPMS (Energy Star) features.
xset s off # disable screen saver
xset s noblank # don't blank the video device
matchbox-window-manager -use_titlebar no &
xrandr --output HDMI-1 --rotate $(cat config/orientation.cfg) &
unclutter &
chromium --noerrdialogs --kiosk --check-for-update-interval=31536000 --no-sandbox --ignore-gpu-blacklist http://localhost:3000/startup