#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown MongoDB and CECacheServer Locally"
docker-compose -f docker-compose.app.yml down
docker volume rm 09_mongodb_local_cecacheserver_data
docker-compose -f docker-compose.yml down
docker volume rm 09_mongodb_local_mongo_data
docker volume rm 09_mongodb_local_mongo_config
docker volume rm 09_mongodb_local_mongoclient_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results  ${experiment} "09_MongoDB_Local: Shutdown MongoDB and CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../endExperiment.sh