#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Startup Cassandra/CassandraWeb/CECacheServer Locally"
docker volume rm 05_Cassandra_local_cassandra_data
docker volume rm 05_Cassandra_local_cassandraweb_data
docker volume rm 05_Cassandra_local_cecacheserver_data
docker-compose -f docker-compose.yml up -d

figlet -w 240 -f small "Wait For Cassandra To Start"
while true ; do
  docker logs cassandra_container > stdout.txt 2> stderr.txt
  result=$(grep -c "Created default superuser role '"'"'cassandra'"'"'" stdout.txt)
  if [ $result = 1 ] ; then
    echo "Cassandra has started"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
../../getDataAsCSVline.sh .results "Howard Deiner" "Local Startup Cassandra" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv