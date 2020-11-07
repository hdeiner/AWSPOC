#!/usr/bin/env bash

figlet -w 160 -f small "Startup MongoDB/MongoClient Locally"
docker volume rm 09_mongodb_local_mongo_data
docker volume rm 09_mongodb_local_mongoclient_data
docker-compose -f docker-compose.yml up -d

figlet -w 160 -f small "Wait For MongoDB To Start"
while true ; do
  docker logs mongodb_container > stdout.txt 2> stderr.txt
  result=$(grep -cE "Waiting for connections.*port.*27017" stdout.txt)
  if [ $result != 0 ] ; then
    echo "MongoDB has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt