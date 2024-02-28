#!/bin/bash
echo "Starting up..."
sleep 1

cd /home/upframe/upframeos && git -c safe.directory=/home/upframe/upframeos pull || echo "git pull failed, but script continues"
sh /home/upframe/upframeos/scripts/create_setup_wifi.sh &

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile
nohup RAILS_ENV=production bundle exec rails s > /dev/null 2>&1 &

#sudo xinit /home/upframe/upframeos/scripts/start_browser.sh
