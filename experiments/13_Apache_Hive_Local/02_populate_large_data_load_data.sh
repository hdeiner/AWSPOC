#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate Hive Data - Large Data - $ROWS rows"

docker cp /tmp/PGYR2019_P06302020.csv hive-server:/tmp/PGYR2019_P06302020.csv

echo "LOAD DATA LOCAL INPATH '/tmp/PGYR2019_P06302020.csv' INTO TABLE PGYR2019_P06302020" > .hive_command
docker cp .hive_command hive-server:/tmp/hive_command
docker exec hive-server beeline -u jdbc:hive2://localhost:10000 --color=true --autoCommit=true -f /tmp/hive_command
echo ""

rm .hive_command