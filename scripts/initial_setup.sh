#!/bin/bash

installPackages() {
    sudo apt-get install matchbox chromium unclutter xorg git hostapd dnsmasq isc-dhcp-server -y
}

createUpFrameUser() {
    # Step 1: Create the user 'upframe' with sudo privileges
    useradd -m -s /bin/bash -G sudo -p $(openssl passwd -1 upframe) upframe
    usermod -a -G tty upframe
    usermod -a -G video upframe
    usermod -a -G input upframe

    # Step 2: Configure sudoers to allow 'upframe' to use sudo without a password
    # Check if the /etc/sudoers.d directory exists, and use it if it does
    if [ -d "/etc/sudoers.d" ]; then
        echo "upframe ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/upframe
        # Ensure the file has the correct permissions
        chmod 0440 /etc/sudoers.d/upframe
    else
        # If /etc/sudoers.d doesn't exist, modify /etc/sudoers directly using visudo
        echo 'upframe ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
    fi

    echo "User 'upframe' has been created and configured for passwordless sudo."
}

configureUpFrameAutoLogin() {
    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
    echo "[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin upframe --noclear %I 38400 linux" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

# Step 2: Ensure startup.sh is executed on login by adding it to .bash_profile
echo "sh /home/upframe/upframeos/scripts/startup.sh" >> /home/upframe/.bash_profile

# Reload systemd manager configuration
sudo systemctl daemon-reload

# Optional: Enable getty@tty1 service to start at boot
# sudo systemctl enable getty@tty1.service

echo "Auto-login setup complete. The user 'upframe' will automatically log in on console."
}

checkoutUpFrameOSSource() {
  git clone https://github.com/appenetic/upframeos /home/upframe/upframeos
  chown -R upframe:upframe /home/upframe/upframeos
}

configureWIFIHotspotFeature() {
  systemctl unmask hostapd
}

createUpFrameUser
installPackages
configureUpFrameAutoLogin
checkoutUpFrameOSSource

reboot