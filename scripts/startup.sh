#!/bin/bash
echo "Starting up..."
sleep 5

cd ~/upframeos && git pull || echo "git pull failed, but script continues"
sh ~/upframeos/scripts/create_setup_wifi.sh &
xinit ~/upframeos/scripts/start_browser.sh
