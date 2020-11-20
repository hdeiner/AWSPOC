#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown Cassandra/CassandraWeb/CECacheServer Locally"
docker-compose -f docker-compose.yml down
docker volume rm 05_cassandra_local_cassandra_data
docker volume rm 05_Cassandra_local_cassandraweb_data
docker volume rm 05_cassandra_local_cecacheserver_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Shutdown Cassandra" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv