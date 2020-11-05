#!/usr/bin/env bash

figlet -w 160 -f small "Populate MongoDB Locally"
docker cp ../../src/db/DERIVEDFACT.csv mongodb_container:/tmp/DERIVEDFACT.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d testdatabase -c DERIVEDFACT --headerline /tmp/DERIVEDFACT.csv"
docker cp ../../src/db/MEMBERHEALTHSTATE.csv mongodb_container:/tmp/MEMBERHEALTHSTATE.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d testdatabase -c MEMBERHEALTHSTATE --headerline /tmp/MEMBERHEALTHSTATE.csv"

figlet -w 160 -f small "Check MongoDB Locally"
echo 'use testdatabase' > .mongo.js
echo 'db.DERIVEDFACT.find()' >> .mongo.js
echo 'db.MEMBERHEALTHSTATE.find()' >> .mongo.js
echo 'exit' >> .mongo.js

docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
rm .mongo.js