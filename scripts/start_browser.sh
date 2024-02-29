#!/bin/bash

# URL to check for Rails app readiness
CHECK_URL="http://localhost:3000"

# Function to check if the Rails app is ready
check_rails_ready() {
    while true; do
        if curl --silent --fail $CHECK_URL; then
            echo "Rails app is ready."
            return 0
        else
            echo "Rails app is not ready yet. Retrying..."
            sleep 5 # Wait for 5 seconds before retrying
        fi
    done
}

# Wait for Rails app to become ready
if check_rails_ready; then
    # Prepare the display environment
    xset -dpms # disable DPMS (Energy Star) features.
    xset s off # disable screen saver
    xset s noblank # don't blank the video device

    # Start window manager and set display properties
    matchbox-window-manager -use_titlebar no &
    xrandr --output HDMI-1 --rotate $(cat config/orientation.cfg) &
    unclutter &

    # Start the browser
    chromium --noerrdialogs --kiosk --check-for-update-interval=31536000 --no-sandbox --ignore-gpu-blacklist http://localhost/startup
fi
