#!/bin/bash
echo "Starting up..."

git pull ~/upframeos
sh ~/upframeos/scripts/create_setup_wifi.sh &
#xinit ~/upframeos/scripts/start_browser.sh
