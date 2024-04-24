#!/bin/bash
exec &> /home/upframe/upframeos/logs/start_browser.log

# URL to check for Rails app readiness
CHECK_URL="http://localhost"

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
     echo "Starting chromium..."
     chromium \
	     --enable-features=UseOzonePlatform \
	     --ozone-platform=wayland \
	     --ignore-gpu-blocklist \
	     --enable-gpu-rasterization \
	     --enable-zero-copy \
	     --disable-gpu-driver-bug-workarounds \
	     --use-gl=egl \
	     --kiosk "http://localhost/startup"
fi