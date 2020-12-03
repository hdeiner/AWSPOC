#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Startup CECacheServer Locally"
docker volume rm 01_postgres_local_cecacheserver_data
docker-compose -f docker-compose.app.yml up -d --build

echo "Wait For CECacheServer To Start"
while true ; do
  docker logs cecacheserver_forpostgres_container > stdout.txt 2> stderr.txt
  result=$(grep -cE "<<<<< Local Cache Statistics <<<<<" stdout.txt)
  if [ $result != 0 ] ; then
    echo "CECacheServer has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "03_MySQL_Local: Startup CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
docker logs cecacheserver_forpostgres_container | grep -E "Timing for get" > .result
while IFS= read -r line
do
	table=$(echo $line | perl -n -e'/.*Timing for get(.*)\:/ && print $1')
  ms=$(echo $line | perl -n -e'/.*Timing for get'$table'\: (\d*)/ && print $1')
  sec=$(echo 'scale=3;'$ms'/1000' | bc | sed 's/^\./0./')

  experimenter=$experiment
  timestamp=$(date --utc)
  system=$(uname -snrmo)
  memory=$(free -h)
  totalmemory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $1')
  usedmemory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $2')
  freememory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $3')
  sharedmemory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $4')
  buffcachememory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $5')
  availablememory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $6')
  totalswap=$(echo $memory | perl -n -e'/.*Swap:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $1')
  usedswap=$(echo $memory | perl -n -e'/.*Swap:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $2')
  freeswap=$(echo $memory | perl -n -e'/.*Swap:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $3')
  command="03_MySQL_Local: Startup CECacheServer Locally Table: "$table
  usertime=""
  systemtime=""
  percentcpu=""
  elapsedtime=$sec
  maxresidentsetsize=""
  avgresidentsetsize=""
  majorpagefaults=""
  minorpagefaults=""
  voluntarycontextswitches=""
  involuntarycontextswitches=""
  swaps=""
  filesysteminputs=""
  filesystemoutputs=""
  socketmessagessent=""
  socketmessagesreceived=""
  signalsdelivered=""
  pagesize=""
  echo "$experimenter,$timestamp,$system,$totalmemory,$usedmemory,$freememory,$sharedmemory,$buffcachememory,$availablememory,$totalswap,$usedswap,$freeswap,$command,$usertime,$systemtime,$percentcpu,$elapsedtime,$maxresidentsetsize,$avgresidentsetsize,$majorpagefaults,$minorpagefaults,$voluntarycontextswitches,$involuntarycontextswitches,$swaps,$filesysteminputs,$filesystemoutputs,$socketmessagessent,$socketmessagesreceived,$signalsdelivered,$pagesize" >> Experimental\ Results.csv
done < .result
rm .result

../../putExperimentalResults.sh
