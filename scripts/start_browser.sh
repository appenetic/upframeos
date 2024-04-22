#!/bin/bash

# URL to check for Rails app readiness
CHECK_URL="http://upframe.lan"

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
    chromium --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --test-type --ignore-gpu-blacklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers "http://upframe.lan/startup"
fi
