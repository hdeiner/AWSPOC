#!/usr/bin/env bash

figlet -w 160 -f small "Startup Oracle Locally"
docker volume rm 07_oracle_local_oracle_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For Oracle To Start"
while true ; do
  docker logs oracle_container > stdout.txt 2> stderr.txt
  result=$(grep -c "Done ! The database is ready for use ." stdout.txt)
  if [ $result = 1 ] ; then
    sleep 60 # it only thinks it is started
    echo "Oracle has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt