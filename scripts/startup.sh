#!/bin/bash
echo "Starting up..."
sleep 1

cd /home/upframe/upframeos && git pull || echo "git pull failed, but script continues"
sh /home/upframe/upframeos/scripts/create_setup_wifi.sh &
sudo xinit /home/upframe/upframeos/scripts/start_browser.sh
