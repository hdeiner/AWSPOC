#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate MongoDB Data - Large Data - $ROWS rows"
head -n `echo "$ROWS+1" | bc` /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
docker cp /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv mongodb_container:/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d PGYR19_P063020 -c PI --headerline /tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv"
