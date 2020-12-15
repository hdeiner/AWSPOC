#!/usr/bin/env bash

if [ $# -eq 0 ]
  then
    echo "must supply the command with the number of rows to use"
    exit 1
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
    echo "must supply the command with the number of rows to use"
   exit 1
fi

ROWS=$1
export ROWS

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash

echo $1

figlet -w 240 -f small "Populate MongoDB Locally - Large Data - $(numfmt --grouping $ROWS) rows"

#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transferPGYR19_P063020_from_s3_and_decrypt.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Get Data from S3 Bucket - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

command time -v ./02_populate_large_data_load_data.sh $ROWS 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Populate Oracle Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check MongoDB Data - Large Data - $(numfmt --grouping $ROWS) rows"

echo "First two rows of data"
echo "use PGYR19_P063020" > .mongo.js
echo "db.PI.find().limit(2).pretty()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"

echo "Count of rows of data"
echo "use PGYR19_P063020" > .mongo.js
echo "db.PI.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"

echo "Average of Total_Amount_of_Payment_USDollars"
echo "use PGYR19_P063020" > .mongo.js
echo "db.PI.aggregate([{\$group: {_id:null, Total_Amount_of_Payment_USDollars: {\$avg:""\"""\$Total_Amount_of_Payment_USDollars""\"""} } }])" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"

echo ""
echo "Top ten earning physicians"
docker cp 02_populate_large_data_top_10_earning_phyicians.txt mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Check Oracle Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results .mongo.js /tmp/PGYR19_P063020