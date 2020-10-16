#!/usr/bin/env bash

figlet -w 160 -f small "Startup Postgres Locally"
docker volume rm postgres_local_postgres_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For Postgres To Start"
while true ; do
  docker logs postgres_container > stdout.txt 2> stderr.txt
  result=$(grep -c "LOG:  database system is ready to accept connections" stderr.txt)
  if [ $result = 1 ] ; then
    echo "Postgres has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt