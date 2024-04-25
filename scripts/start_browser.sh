#!/bin/bash
exec &> /home/upframe/upframeos/logs/start_browser.log

# URL to check for Rails app readiness
CHECK_URL="http://localhost"
CONFIG_FILE="/home/upframe/upframeos/config/chromium.conf"

# Function to check if the Rails app is ready
check_rails_ready() {
    while true; do
        if curl --silent --fail $CHECK_URL; then
            echo "Rails app is ready."
            return 0
        else
            echo "Rails app is not ready yet. Retrying..."
            sleep 2 # Wait for 5 seconds before retrying
        fi
    done
}

# Load Chromium options from configuration file
if [ -f "$CONFIG_FILE" ]; then
    source $CONFIG_FILE
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Wait for Rails app to become ready
if check_rails_ready; then
    echo "Starting chromium..."
    chromium $CHROMIUM_OPTIONS "http://localhost/startup"
fi