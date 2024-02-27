#!/bin/bash

stop_hotspot() {
    echo "Stopping hotspot..."
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    sudo systemctl stop dhcpcd
    echo "Hotspot stopped."
}

# Define the destination path for the wpa_supplicant.conf file
WPA_SUPPLICANT_CONF_PATH="/etc/wpa_supplicant/wpa_supplicant.conf"

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Check if content is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 'wpa_supplicant_conf_content'"
  exit 1
fi

# The content of wpa_supplicant.conf is passed as the first argument
WPA_CONTENT="$1"

# Write the content to the wpa_supplicant.conf file
echo "$WPA_CONTENT" > "$WPA_SUPPLICANT_CONF_PATH"

# Verify the file was written successfully
if [ $? -eq 0 ]; then
  echo "wpa_supplicant.conf has been updated successfully."
  stop_hotspot
else
  echo "Failed to write wpa_supplicant.conf. Check your permissions or path."
  exit 1
fi

