#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"

aws ec2 describe-instances --region "us-east-1" --instance-id "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --query 'Reservations[].Instances[].[Tags[0].Value]' --output text > .instanceName
sed --in-place --regexp-extended 's/ /_/g' .instanceName

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Get Data from S3 Bucket"
/tmp/transfer_from_s3_and_decrypt.sh ce.ClinicalCondition.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
/tmp/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh .results ${experiment} "10_MongoDB_AWS: Get Data from S3 Bucket "$(<.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into CSV Files For Import"
/tmp/transform_Oracle_ce.ClinicalCondition_to_csv.sh
/tmp/transform_Oracle_ce.DerivedFact_to_csv.sh
/tmp/transform_Oracle_ce.DerivedFactProductUsage_to_csv.sh
/tmp/transform_Oracle_ce.MedicalFinding_to_csv.sh
/tmp/transform_Oracle_ce.MedicalFindingType_to_csv.sh
/tmp/transform_Oracle_ce.OpportunityPointsDiscr_to_csv.sh
/tmp/transform_Oracle_ce.ProductFinding_to_csv.sh
/tmp/transform_Oracle_ce.ProductFindingType_to_csv.sh
/tmp/transform_Oracle_ce.ProductOpportunityPoints_to_csv.sh
/tmp/transform_Oracle_ce.Recommendation_to_csv.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh .results ${experiment} "10_MongoDB_AWS: Process S3 Data into CSV Files For Import "$(<.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Populate MongoDB Data"
echo "Clinical_Condition"
mongoimport --type csv -d ce -c Clinical_Condition --headerline ce.ClinicalCondition.csv
echo "DerivedFact"
mongoimport --type csv -d ce -c DerivedFact --headerline ce.DerivedFact.csv
echo "DerivedFactProductUsage"
mongoimport --type csv -d ce -c DerivedFactProductUsage --headerline ce.DerivedFactProductUsage.csv
echo "MedicalFinding"
mongoimport --type csv -d ce -c MedicalFinding --headerline ce.MedicalFinding.csv
echo "MedicalFindingType"
mongoimport --type csv -d ce -c MedicalFindingType --headerline ce.MedicalFindingType.csv
echo "OpportunityPointsDiscr"
mongoimport --type csv -d ce -c OpportunityPointsDiscr --headerline ce.OpportunityPointsDiscr.csv
echo "ProductFinding"
mongoimport --type csv -d ce -c ProductFinding --headerline ce.ProductFinding.csv
echo "ProductFindingType"
mongoimport --type tsv -d ce -c ProductFindingType --headerline ce.ProductFindingType.csv
echo "ProductOpportunityPoints"
mongoimport --type tsv -d ce -c ProductOpportunityPoints --headerline ce.ProductOpportunityPoints.csv
echo "Recommendation"
mongoimport --type csv -d ce -c Recommendation --headerline ce.Recommendation.csv
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh .results  ${experiment}  "10_MongoDB_AWS: Populate MongoDB Data "$(<.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Check MongoDB Data"
echo "Clinical_Condition"
echo "use ce" > .mongo.js
echo "db.Clinical_Condition.find().limit(2)" >> .mongo.js
echo "db.Clinical_Condition.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "DerivedFact"
echo "use ce" > .mongo.js
echo "db.DerivedFact.find().limit(2)" >> .mongo.js
echo "db.DerivedFact.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "MedicalFinding"
echo "use ce" > .mongo.js
echo "db.MedicalFinding.find().limit(2)" >> .mongo.js
echo "db.MedicalFinding.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "MedicalFindingType"
echo "use ce" > .mongo.js
echo "db.MedicalFindingType.find().limit(2)" >> .mongo.js
echo "db.MedicalFindingType.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "OpportunityPointsDiscr"
echo "use ce" > .mongo.js
echo "db.OpportunityPointsDiscr.find().limit(2)" >> .mongo.js
echo "db.OpportunityPointsDiscr.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "ProductFinding"
echo "use ce" > .mongo.js
echo "db.ProductFinding.find().limit(2)" >> .mongo.js
echo "db.ProductFinding.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "ProductFindingType"
echo "use ce" > .mongo.js
echo "db.ProductFindingType.find().limit(2)" >> .mongo.js
echo "db.ProductFindingType.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "ProductOpportunityPoints"
echo "use ce" > .mongo.js
echo "db.ProductOpportunityPoints.find().limit(2)" >> .mongo.js
echo "db.ProductOpportunityPoints.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
echo "Recommendation"
echo "use ce" > .mongo.js
echo "db.Recommendation.find().limit(2)" >> .mongo.js
echo "db.Recommendation.count()" >> .mongo.js
echo "exit" >> .mongo.js
mongo < .mongo.js
EOF'
chmod +x .script
command time -v ./.script 2> .results
/tmp/getExperimentalResults.sh
experiment=$(/tmp/getExperimentNumber.sh)
/tmp/getDataAsCSVline.sh .results ${experiment} "10_MongoDB_AWS: Check MongoDB Data "$(<.instanceName) >> Experimental\ Results.csv
/tmp/putExperimentalResults.sh
rm .script .mongo.js .results *.csv