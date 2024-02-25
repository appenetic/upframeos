#!/bin/bash

# Define the interface name
wifi_interface="wlan0"

# Check if the WiFi is currently connected
wifi_status=$(nmcli device status | grep "$wifi_interface" | awk '{print $3}')

if [ "$wifi_status" != "connected" ]; then
    echo "WiFi is not connected. Setting up hotspot..."
    sudo nmcli device wifi hotspot ssid upframe password upframe ifname "$wifi_interface"
else
    echo "WiFi is already connected. No action taken."
fi