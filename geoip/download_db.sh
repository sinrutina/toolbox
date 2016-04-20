#!/bin/bash
# Download and configure geoip database
server_address="$1"
server_shared_folder="$2"
option="${3-n}"

if [ "-z" $server_address ] || [ "-z" $server_shared_folder ]
then
  echo You have to provide
  echo - a server address
  echo - a path to the shared folder of the server
else
  if ! ssh $server_address "[ -d $server_shared_folder ]"
  then
    # Folder not found
    echo 'Folder not found on server'
    echo 'Make sure the path to the shared folder is ok'
    exit 1
  fi
fi

if [ $option = "-d" ]
then
  echo "==== Downloading db ===="
  ssh -t $server_address "mkdir -p $server_shared_folder/lib/geoip &&
      curl -o $server_shared_folder/lib/geoip/database.mmdb.gz http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz &&
      gunzip $server_shared_folder/lib/geoip/database.mmdb.gz"
fi

if [ $option = "-u" ]
then
  echo "==== Enabling updates ===="

  echo '===== Installing geoip update software ====='
  ssh -t $server_address "sudo add-apt-repository -y ppa:maxmind/ppa &&
    sudo apt update && sudo apt install -y geoipupdate"

  echo '===== Configuring update ====='
  conf_file="/usr/local/etc/GeoIP.conf"
  config="'# The following UserId and LicenseKey are required placeholders:
UserId 999999
LicenseKey 000000000000

# Include one or more of the following ProductIds:
# * GeoLite2-City - GeoLite 2 City
# * GeoLite2-Country - GeoLite2 Country
# * GeoLite-Legacy-IPv6-City - GeoLite Legacy IPv6 City
# * GeoLite-Legacy-IPv6-Country - GeoLite Legacy IPv6 Country
# * 506 - GeoLite Legacy Country
# * 517 - GeoLite Legacy ASN
# * 533 - GeoLite Legacy City
ProductIds GeoLite2-Country
'"
  ssh -t $server_address "sudo touch $conf_file &&
    sudo chmod 777 $conf_file &&
    echo $config > $conf_file
  "

  cron="29 9 * * 5 $(which geoipupdate)"
  echo '===== Creating cronfile ====='
  cron_file="$server_shared_folder/lib/geoip/update_cron"
  ssh -t $server_address "touch $cron_file &&
    crontab -l > $cron_file &&
    echo $cron >> $cron_file && crontab $cron_file && rm $cron_file"

  echo '===== Done ====='
fi

