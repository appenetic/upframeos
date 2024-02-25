#!/bin/sh

# Install required packages
sudo apt-get install matchbox chromium unclutter xorg git

# Create upframe user account
sudo useradd -m -s /bin/bash -G sudo -p $(openssl passwd -1 upframe) upframe