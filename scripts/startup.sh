#!/bin/bash
echo "Starting up..."
sleep 1

cd /home/upframe/upframeos && git -c safe.directory=/home/upframe/upframeos pull || echo "git pull failed, but script continues"
sh /home/upframe/upframeos/scripts/create_setup_wifi.sh &

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
else
  echo "RVM not found"
fi

source /home/upframe/.bash_profile || source /home/upframe/.bashrc

RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile
nohup RAILS_ENV=production bundle exec rails s > /dev/null 2>&1 &

#sudo xinit /home/upframe/upframeos/scripts/start_browser.sh
