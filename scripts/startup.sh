#!/bin/bash
echo "Starting up..."
sleep 100

cd ~/upframeos && git pull
sh ~/upframeos/scripts/create_setup_wifi.sh &
xinit ~/upframeos/scripts/start_browser.sh
