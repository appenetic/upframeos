#!/bin/sh
DISPLAY=:0.0 xrandr --output HDMI-1 --rotate "$1" &
echo "$1" > config/orientation.cfg