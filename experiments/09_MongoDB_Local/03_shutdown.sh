#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown MongoDB/MongoClient Locally"
docker-compose -f docker-compose.yml down
docker volume rm 09_mongodb_local_mongo_data
docker volume rm 09_mongodb_local_mongoclient_data