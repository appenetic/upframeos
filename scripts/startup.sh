#!/bin/bash
echo "Starting up..."

cd ~/upframeos && git pull
sh ~/upframeos/scripts/create_setup_wifi.sh &
#xinit ~/upframeos/scripts/start_browser.sh
