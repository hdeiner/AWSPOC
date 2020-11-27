#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Startup CECacheServer Locally"
docker volume rm 09_mongodb_local_cecacheserver_data
docker-compose -f docker-compose.app.yml up -d --build
echo "Wait For CECacheServer To Start"
while true ; do
  docker logs cecacheserver_formongodb_container > stdout.txt 2> stderr.txt
#  result=$(grep -cE "<<<<< Local Cache Statistics <<<<<" stdout.txt) cecacheserver_formongodb_container is failing!
  result=$(grep -cE "using Agent sizeof engine" stdout.txt)
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
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Startup CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv