#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Shutdown Ignite Locally"
docker-compose -f docker-compose.yml down
docker volume rm 11_ignite_local_ignite_data
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "11_Ignite_Local: Shutdown Ignite Locally" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv