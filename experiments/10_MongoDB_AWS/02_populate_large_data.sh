#!/usr/bin/env bash

ROWS=$(</tmp/.rows)
export ROWS

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > /tmp/.instanceName
sed --in-place --regexp-extended 's/ /_/g' /tmp/.instanceName

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"
figlet -w 240 -f small "Populate MongoDB AWS - Large Data - $(numfmt --grouping $ROWS) rows"
figlet -w 240 -f small "Get Data from S3 Bucket"
/tmp/transferPGYR19_P063020_from_s3_and_decrypt.sh > /dev/null
EOF'
chmod +x /tmp/.script
command time -v /tmp/.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "10_MongoDB_AWS: Get Data from S3 Bucket "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm /tmp/.script /tmp/.results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

command time -v /tmp/02_populate_large_data_load_data.sh $ROWS 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "10_MongoDB_AWS: Populate MongoDB Data "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm -rf /tmp/.script /tmp/.results Experimental\ Results.csv

bash -c 'cat << "EOF" > /tmp/.script
#!/usr/bin/env bash
figlet -w 240 -f small "Check MongoDB Data - Large Data - $(numfmt --grouping $ROWS) rows"

echo "First two rows of data"
echo "use PGYR19_P063020" > /tmp/.mongo.js
echo "db.PI.find().limit(2).pretty()" >> /tmp/.mongo.js
echo "exit" >> /tmp/.mongo.js
mongo < /tmp/.mongo.js

echo "Count of rows of data"
echo "use PGYR19_P063020" > /tmp/.mongo.js
echo "db.PI.count()" >> /tmp/.mongo.js
echo "exit" >> /tmp/.mongo.js
mongo < /tmp/.mongo.js

echo "Average of Total_Amount_of_Payment_USDollars"
echo "use PGYR19_P063020" > /tmp/.mongo.js
echo "db.PI.aggregate([{\$group: {_id:null, Total_Amount_of_Payment_USDollars: {\$avg:""\"""\$Total_Amount_of_Payment_USDollars""\"""} } }])" >> /tmp/.mongo.js
echo "exit" >> /tmp/.mongo.js
mongo < /tmp/.mongo.js

echo ""
echo "Top ten earning physicians"
mongo < /tmp/02_populate_large_data_top_10_earning_phyicians.txt
EOF'
chmod +x /tmp/.script
command time -v /tmp/.script 2> /tmp/.results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh /tmp/.results ${experiment} "10_MongoDB_AWS: Check MongoDB Data "$(</tmp/.instanceName)" - Large Data - $ROWS rows" >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm -rf /tmp/.script /tmp/.results /tmp/command.sql /tmp/*.csv /tmp/PGYR19_P063020