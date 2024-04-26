#!/bin/bash

UPFRAMEOS_DIR="/home/upframe/upframeos/app"
LOG_FILE="/home/upframe/log.log"

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

cd "$UPFRAMEOS_DIR" || {
  log_message "Error: Could not change directory to '$UPFRAMEOS_DIR'."
  exit 1
}

if DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production rake db:drop &>> "$LOG_FILE"; then
  log_message "Database dropped successfully."
else
  log_message "Error: Database drop failed."
  exit 1
fi

if RAILS_ENV=production rake db:create &>> "$LOG_FILE"; then
  log_message "Database create successfully."
else
  log_message "Error: Database create failed."
  exit 1
fi

if RAILS_ENV=production rake db:migrate &>> "$LOG_FILE"; then
  log_message "Database migrated successfully."
else
  log_message "Error: Database migration failed."
  exit 1
fi

if RAILS_ENV=production rake db:seed &>> "$LOG_FILE"; then
  log_message "Database seeded successfully."
else
  log_message "Error: Database seeding failed."
  exit 1
fi

if sudo rm -rf /etc/wpa_supplicant/wpa_supplicant.conf; then
  log_message "WiFi configuration successfully deleted."
else
  log_message "Error: Wifi configuration delete failed."
  exit 1
fi

log_message "Upframe successfully reset to factory defaults."
sudo reboot