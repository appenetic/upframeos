#!/bin/bash
echo "Starting up..."
sleep 1

cd /home/upframe/upframeos && git -c safe.directory=/home/upframe/upframeos pull || echo "git pull failed, but script continues"
#sh /home/upframe/upframeos/scripts/create_setup_wifi.sh &

echo $PATH
export PATH="$PATH:/home/upframe/.rvm/bin"
echo $PATH
source /home/upframe/.bash_profile || source /home/upframe/.bashrc
source /home/upframe/.rvm/scripts/rvm

cd /home/upframe/upframeos/app/
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile

start_server() {
    RAILS_ENV=production bundle exec rails s -d
    echo "Rails server started."
}

# Function to wait for the server to become responsive
wait_for_server() {
    while true; do
        echo "Waiting for Rails server to start..."
        while ! nc -z localhost 3000; do
            echo "Waiting for application server to become responsive..."
            sleep 1 # wait for 1 second before checking again
        done

        echo "Rails server is responsive."

        # Server is up; now checking continuously for responsiveness
        while nc -z localhost 3000; do
            echo "Server is up and running."
            sleep 10 # check every 10 seconds to reduce load
        done

        echo "Server is not responsive. Attempting to restart."
        # Kill the existing server process before restarting
        # This step depends on how you're running your Rails server.
        # For example, you might need to kill a specific PID or use pkill to kill the process by name
        # pkill -f 'rails' # Uncomment and adjust according to your server process
        start_server # Restart the server
    done
}

start_server
wait_for_server

#sudo xinit /home/upframe/upframeos/scripts/start_browser.sh
