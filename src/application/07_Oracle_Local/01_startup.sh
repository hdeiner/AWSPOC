#!/usr/bin/env bash

figlet -w 160 -f small "Startup CE CacheServer Locally"

figlet -w 160 -f small "Wait For CE CacheServer To Start"
cd ./deploy/bin/
./runcachesvr.sh
./logcachesvr.sh

