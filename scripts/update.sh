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

GIT_PULL_OUTPUT=$(git pull)
echo "$GIT_PULL_OUTPUT" >> "$LOG_FILE"
if [[ "$GIT_PULL_OUTPUT" == *"Already up to date."* ]]; then
  log_message "No changes detected in Git repository. Exiting script."
  exit 0  # No updates, no need for restart
else
  log_message "Git pull detected changes."
fi

if RAILS_ENV=production rake db:migrate &>> "$LOG_FILE"; then
  log_message "Database migrations completed successfully."
else
  log_message "Error: Database migrations failed."
  exit 1
fi

if RAILS_ENV=production rake db:seed &>> "$LOG_FILE"; then
  log_message "Database seeding completed successfully."
else
  log_message "Error: Database seeding failed."
  exit 1
fi

if RAILS_ENV=production rake assets:precompile &>> "$LOG_FILE"; then
  log_message "Assets precompilation successful."
else
  log_message "Error: Assets precompilation failed."
  exit 1
fi

log_message "Upframe update script completed."
exit 2  # Indicates updates were applied and a restart is needed
