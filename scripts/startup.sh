#!/bin/bash
echo "Starting up..."
sleep 1

cd /home/upframe/upframeos && git -c safe.directory=/home/upframe/upframeos pull || echo "git pull failed, but script continues"
#sh /home/upframe/upframeos/scripts/create_setup_wifi.sh &

export PATH="$PATH:/home/upframe/.rvm/bin"
source /home/upframe/.bash_profile || source /home/upframe/.bashrc

cd /home/upframe/upframeos/app/
RAILS_ENV=production bundle exec rake db:create || true
RAILS_ENV=production bundle exec rake db:migrate || true
RAILS_ENV=production bundle exec rake assets:precompile || true
nohup RAILS_ENV=production bundle exec rails s > /dev/null 2>&1 &

#sudo xinit /home/upframe/upframeos/scripts/start_browser.sh
