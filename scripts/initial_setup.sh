#!/bin/bash

installPackages() {
    sudo apt-get install matchbox chromium unclutter xorg git hostapd dnsmasq dhcpcd lighttpd vim -y
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

    sudo -u upframe touch /home/upframe/.hushlogin
    echo "User 'upframe' has been created and configured for passwordless sudo."
}

configureUpFrameAutoLogin() {
    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
    echo "[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin upframe --noclear %I 38400 linux" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

# Step 2: Ensure startup.sh is executed on login by adding it to .bash_profile
echo "sh /home/upframe/upframeos/scripts/startup.sh" >> /home/upframe/.bash_profile
chown upframe:upframe /home/upframe/.bash_profile

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
  sudo systemctl disable hostapd

  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
  cp "${SCRIPT_DIR}/../config/hostapd.conf" /etc/hostapd/hostapd.conf

  echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd
  echo 'interface wlan0\nstatic ip_address=192.168.1.1/24' >> /etc/dhcpcd.conf
}

installRMV() {
  sudo -u upframe bash -c '\curl -sSL https://get.rvm.io | bash'
  sudo -u upframe bash -c 'source "$HOME/.rvm/scripts/rvm" && rvm install ruby-3.2.2'
}

installBundles() {
  sudo -u upframe bash -c '
    source /home/upframe/.rvm/scripts/rvm || { echo "Failed to source RVM"; exit 1; }
    cd /home/upframe/upframeos/app || { echo "Failed to change directory"; exit 1; }
    bundle install || { echo "Bundle install failed"; exit 1; }
  '
}

cleanup() {
  touch ~/.hushlogin
  echo "" > /etc/wpa_supplicant/wpa_supplicant.conf
  rm -rf /root/upframeos
}

createUpFrameUser
installPackages
configureUpFrameAutoLogin
checkoutUpFrameOSSource
configureWIFIHotspotFeature
installRMV
installBundles

cleanup
reboot