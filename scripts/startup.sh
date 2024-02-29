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
#RAILS_ENV=production bundle exec rake db:create
#RAILS_ENV=production bundle exec rake db:migrate
#RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rails s -d

wait_for_server() {
    echo "Waiting for Rails server to start..."
    while ! nc -z localhost 3000; do
      echo "waiting for application server to become responsive"
      sleep 1 # wait for 1 second before check again
    done
    echo "Rails server started."
}

wait_for_server

sudo xinit /home/upframe/upframeos/scripts/start_browser.sh
