 #!/bin/bash
source_heroku_app="$1"
dest_url="$2"
option="${3-n}"

IFS='@' read -r user host <<< $dest_url
IFS=":" read -r -a user <<< $user
IFS=":/" read -r -a host <<< $host

echo copying from $source_heroku_app to $dest_url
echo ""
echo "user name: ${user[0]} password: ${user[1]}"
echo "host name ${host[0]} port: ${host[1]} database name: ${host[2]}"
echo ""

if [ $option = "-s" ]
then
  echo skipping backup, using last backup from $source_heroku_app
  echo ""
else
  heroku pg:backups capture --app $source_heroku_app
fi

curl -o latest.dump `heroku pg:backups public-url --app $source_heroku_app`
pg_restore --verbose --clean --no-acl --no-owner -h ${host[0]} -p ${host[1]} -U ${user[0]} -d ${host[2]} latest.dump
