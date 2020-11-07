#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

figlet -w 160 -f small "Populate MongoDB AWS"
mongoimport --type csv -d testdatabase -c DERIVEDFACT --headerline /tmp/DERIVEDFACT.csv
mongoimport --type csv -d testdatabase -c MEMBERHEALTHSTATE --headerline /tmp/MEMBERHEALTHSTATE.csv

figlet -w 160 -f small "Check MongoDB AWS"
echo 'use testdatabase' > /tmp/.mongo.js
echo 'db.DERIVEDFACT.find()' >> /tmp/.mongo.js
echo 'db.MEMBERHEALTHSTATE.find()' >> /tmp/.mongo.js
echo 'exit' >> /tmp/.mongo.js

mongo < /tmp/.mongo.js

