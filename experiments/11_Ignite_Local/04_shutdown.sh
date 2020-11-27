#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown Ignite and CECacheServer Locally"
docker-compose -f docker-compose.app.yml down
docker volume rm 11_ignite_local_cecacheserver_data
docker-compose -f docker-compose.yml -f docker-compose.app.yml down
docker volume rm 11_ignite_local_ignite_data
docker volume rm 11_ignite_local_cecacheserver_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results  ${experiment} "11_Ignite_Local: Shutdown Ignite and CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../endExperiment.sh