#!/bin/bash
# Connect via ssh and run console

server_address="$1"
second_config="$2"

if [ "-z" $server_address ]
then
  echo You have to provide an address
else
  echo Connecting to $server_address
  if [ $second_config = "-2" ]
  then
    ssh -t $server_address "bash -l -c -i 'cd apps/sinrutina/current; RAILS_ENV=production bundle exec rails c;'"
  else
    ssh -t $server_address "bash -l -c -i 'cd /var/www/app; RAILS_ENV=production bundle exec rails c;'"
  fi
fi

