#!/bin/bash

# The wireless interface, change wlan0 if different
WIFI_INTERFACE="wlan0"

# Function to start hotspot
start_hotspot() {
    echo "Starting hotspot..."
    sudo systemctl enable dhcpcd
    sudo systemctl enable dnsmasq
    sudo systemctl enable hostapd

    sudo systemctl start hostapd
    sudo systemctl start dnsmasq
    sudo systemctl start dhcpcd
    echo "Hotspot started."
}

# Function to stop hotspot
stop_hotspot() {
    echo "Stopping hotspot..."
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    sudo systemctl stop dhcpcd

    # Check if services are enabled before disabling
    DHCPCD_STATUS=$(systemctl is-enabled dhcpcd)
    if [ "$DHCPCD_STATUS" = "enabled" ]; then
        sudo systemctl disable dhcpcd
    fi

    DNSMASQ_STATUS=$(systemctl is-enabled dnsmasq)
    if [ "$DNSMASQ_STATUS" = "enabled" ]; then
        sudo systemctl disable dnsmasq
    fi

    HOSTAPD_STATUS=$(systemctl is-enabled hostapd)
    if [ "$HOSTAPD_STATUS" = "enabled" ]; then
        sudo systemctl disable hostapd
    fi

    echo "Hotspot stopped."
}

# Check if WiFi is connected
WIFI_CONNECTED=$(sudo iwgetid -r)
if [ -z "$WIFI_CONNECTED" ]; then
    echo "WiFi is not connected."
    # Check if the hotspot is already running to avoid starting it multiple times
    HOSTAPD_STATUS=$(systemctl is-active hostapd)
    if [ "$HOSTAPD_STATUS" != "active" ]; then
        start_hotspot
    else
        echo "Hotspot is already running."
    fi
else
    echo "WiFi is connected to $WIFI_CONNECTED."
    stop_hotspot
fi
