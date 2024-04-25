#!/bin/bash

# Set directory and log file paths (modify as needed)
UPFRAMEOS_DIR="/home/upframe/upframeos/app"
LOG_FILE="/home/upframe/update.log"

# Change directory to the Upframe app directory
cd "$UPFRAMEOS_DIR" || {
  echo "Error: Could not change directory to '$UPFRAMEOS_DIR'."
  exit 1
}

# Perform Git pull with detailed logging (including standard output and error)
git pull &>> "$LOG_FILE"

# Run database migrations in production environment with logging
RAILS_ENV=production rake db:migrate &>> "$LOG_FILE"

# Precompile assets in production environment with logging
RAILS_ENV=production rake assets:precompile &>> "$LOG_FILE"

# Restart Upframe service with logging (consider using systemctl is-active to check status beforehand)
sudo systemctl restart weston upframe &>> "$LOG_FILE"

echo "Upframe update script completed. Check the log file '$LOG_FILE' for details."