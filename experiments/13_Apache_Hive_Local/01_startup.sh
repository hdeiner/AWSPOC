#!/usr/bin/env bash

../../startExperiment.sh

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Startup Hive Locally"
docker volume rm 13_apache_hive_local_namenode
docker volume rm 13_apache_hive_local_datanode
docker volume rm 13_apache_hive_local_postgresql
docker-compose -f docker-compose.yml up -d

echo "Wait For Hive To Start"
while true ; do
  docker logs hive-server > stdout.txt 2> stderr.txt
  result=$(grep -cE " Starting HiveServer2" stdout.txt)
  if [ $result != 0 ] ; then
    sleep 10 # it says it is ready, but not really
    echo "Hive has started"
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
../../getDataAsCSVline.sh .results ${experiment} "13_Hive_Local: Startup Hive Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv