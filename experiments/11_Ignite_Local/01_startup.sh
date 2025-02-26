#!/usr/bin/env bash

../../startExperiment.sh

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Startup Ignite Locally"
docker volume rm 11_ignite_local_ignite_data
docker-compose -f docker-compose.yml up -d

echo "Wait For Ignite To Start"
while true ; do
  docker logs ignite_container > stdout.txt 2> stderr.txt
  result=$(grep -cE "Ignite node started OK" stdout.txt)
  if [ $result != 0 ] ; then
    echo "Ignite has started"
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
../../getDataAsCSVline.sh .results ${experiment} "11_Ignite_Local: Startup Ignite Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv