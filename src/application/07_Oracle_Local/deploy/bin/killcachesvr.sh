#!/bin/bash

pids=`pgrep -u $USER -f net.ahm.careengine.cecacheserver.CECacheServer`

# Kill with -SIGTERM so that JVM shutdown hooks are run (EHCache uses one when a diskstore is used)
signal=9
#signal=SIGTERM

if [ -n "$1" ] 
then
	signal=$1
fi

for i in ${pids}; do
        echo "Killing ${i}"
       	kill -$signal $i
done

