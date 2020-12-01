#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown Cassandra and CECacheServer Locally"
docker-compose -f docker-compose.app.yml down
docker volume rm 05_cassandra_local_cecacheserver_data
docker-compose -f docker-compose.yml -f docker-compose.app.yml down
docker volume rm 05_cassandra_local_cassandra_data
docker volume rm 05_cassandra_local_cassandra_config
docker volume rm 05_cassandra_local_cassandraweb_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "05_Cassandra_Local: Shutdown Cassandra and CECacheServer Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../endExperiment.sh