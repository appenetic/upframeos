#!/bin/bash

installPackages() {
    sudo apt-get update
    sudo apt-get install -y \
        autoconf \
        automake \
        bison \
        chromium \
        dhcpcd \
        dnsmasq \
        g++ \
        gawk \
        gcc \
        git \
        hostapd \
        libc6-dev \
        libffi-dev \
        libgdbm-dev \
        libgmp-dev \
        libncurses5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libyaml-dev \
        lighttpd \
        make \
        matchbox \
        patch \
        pkg-config \
        sqlite3 \
        unclutter \
        vim \
        xorg \
        zlib1g-dev \
        imagemagick
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

checkoutUpFrameOSSource() {
  git clone https://github.com/appenetic/upframeos /home/upframe/upframeos
  chown -R upframe:upframe /home/upframe/upframeos
  chmod -R 755 /home/upframe/upframeos
}

configureWIFIHotspotFeature() {
  systemctl unmask hostapd
  sudo systemctl disable hostapd

  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
  cp "${SCRIPT_DIR}/../config/hostapd.conf" /etc/hostapd/hostapd.conf
  cp "${SCRIPT_DIR}/../config/dnsmasq.conf" /etc/dnsmasq.conf

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

configureLighttpd() {
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
  cp "${SCRIPT_DIR}/../config/lighttpd.conf" /etc/lighttpd/lighttpd.conf
}

configureUpFrameService() {
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
  cp "${SCRIPT_DIR}/../config/upframe.service" /etc/systemd/system/upframe.service
  systemctl daemon-reload
  systemctl enable upframe
}

configureBrowserAutostartService() {
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
  cp "${SCRIPT_DIR}/../config/start_browser.service" /etc/systemd/system/start_browser.service
  systemctl daemon-reload
  systemctl enable start_browser
}

configureSetupWifiService() {
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
  cp "${SCRIPT_DIR}/../config/setup_wifi.service" /etc/systemd/system/setup_wifi.service
  cp "${SCRIPT_DIR}/../config/setup_wifi.timer" /etc/systemd/system/setup_wifi.timer
  systemctl daemon-reload
  systemctl enable setup_wifi
  systemctl enable setup_wifi.timer
}

initialiseUpFrameService() {
    sudo -u upframe bash -c '
      source /home/upframe/.rvm/scripts/rvm || { echo "Failed to source RVM"; exit 1; }
      cd /home/upframe/upframeos/app || { echo "Failed to change directory"; exit 1; }
      RAILS_ENV=production bundle exec rake db:setup &&
      bundle exec rake assets:precompile
    '
}

configureHostname() {
  hostnamectl set-hostname upframe
}

cleanup() {
  touch ~/.hushlogin
  echo "" > /etc/wpa_supplicant/wpa_supplicant.conf
  rm -rf /root/upframeos
}

configureHostname
createUpFrameUser
installPackages
checkoutUpFrameOSSource
configureWIFIHotspotFeature
installRMV
installBundles
configureLighttpd
configureUpFrameService
configureBrowserAutostartService
initialiseUpFrameService
configureSetupWifiService

cleanup
reboot