#!/bin/bash

# Set directory and log file paths (modify as needed)
UPFRAMEOS_DIR="/home/upframe/upframeos/app"
LOG_FILE="/home/upframe/update.log"

# Function to append messages to log with timestamp
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Change directory to the Upframe app directory
cd "$UPFRAMEOS_DIR" || {
  log_message "Error: Could not change directory to '$UPFRAMEOS_DIR'."
  exit 1
}

# Perform Git pull with detailed logging (including standard output and error)
if git pull &>> "$LOG_FILE"; then
  log_message "Git pull successful."
else
  log_message "Error: Git pull failed."
  exit 1
fi

# Run database migrations in production environment with logging
if RAILS_ENV=production rake db:migrate &>> "$LOG_FILE"; then
  log_message "Database migrations completed successfully."
else
  log_message "Error: Database migrations failed."
  exit 1
fi

# Precompile assets in production environment with logging
if RAILS_ENV=production rake assets:precompile &>> "$LOG_FILE"; then
  log_message "Assets precompilation successful."
else
  log_message "Error: Assets precompilation failed."
  exit 1
fi

# Restart Upframe service with logging (consider using systemctl is-active to check status beforehand)
if sudo systemctl restart weston upframe &>> "$LOG_FILE"; then
  log_message "Services restarted successfully."
else
  log_message "Error: Failed to restart services."
  exit 1
fi

log_message "Upframe update script completed."
echo "Upframe update script completed. Check the log file '$LOG_FILE' for details."
