#!/usr/bin/env bash

figlet -w 160 -f small "Startup MySQL Locally"
docker volume rm 03_mysql_local_mysql_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For MySQL To Start"
while true ; do
  docker logs mysql_container > stdout.txt 2> stderr.txt
  result=$(grep -c "\[System\] \[MY-010931\] \[Server\] /usr/sbin/mysqld: ready for connections." stderr.txt)
  if [ $result = 1 ] ; then
    sleep 10 # it says it's ready for connections, but not really
    echo "MySQL has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt