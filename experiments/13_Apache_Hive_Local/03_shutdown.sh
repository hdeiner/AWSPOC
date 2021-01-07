#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Shutdown Hive Locally"
docker-compose -f docker-compose.yml  down
docker volume rm 13_apache_hive_local_namenode
docker volume rm 13_apache_hive_local_datanode
docker volume rm 13_apache_hive_local_postgresql
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results  ${experiment} "13_Hive_Local: Shutdown Hive Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

../../endExperiment.sh