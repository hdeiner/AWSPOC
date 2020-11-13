#!/usr/bin/env bash

figlet -w 160 -f small "Shutdown CE CacheServer Locally"

cd ./deploy/bin/
./killcachesvr.sh

