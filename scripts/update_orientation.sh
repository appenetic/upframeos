#!/bin/bash

# The first argument is the orientation command
ORIENTATION=$1

# The path to the weston.ini configuration file
CONFIG_FILE="/home/upframe/.config/weston.ini"
LOG_FILE="/home/upframe/log.log"

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the orientation argument is provided
if [ -z "$ORIENTATION" ]; then
    echo "No orientation specified"
    exit 1
fi

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found"
    exit 1
fi

# Update the orientation in the weston.ini file
# We're using sed to find the line containing 'transform=' under the '[output]' section and replace it
sed -i "/^\[output\]$/,/^\[/ s/^transform=.*$/transform=$ORIENTATION/" $CONFIG_FILE

# Check if the sed command was successful
if [ $? -ne 0 ]; then
    log_message "Failed to update screen orientation"
    exit 1
else
    log_message "Orientation updated successfully"
    exit 0
fi