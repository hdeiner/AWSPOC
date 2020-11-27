#!/usr/bin/env bash

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
../../data/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Get Data from S3 Bucket" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Process S3 Data into CSV Files For Import"
../transform_Oracle_ce.ClinicalCondition_to_csv.sh
../transform_Oracle_ce.DerivedFact_to_csv.sh
../transform_Oracle_ce.DerivedFactProductUsage_to_csv.sh
../transform_Oracle_ce.MedicalFinding_to_csv.sh
../transform_Oracle_ce.MedicalFindingType_to_csv.sh
../transform_Oracle_ce.OpportunityPointsDiscr_to_csv.sh
../transform_Oracle_ce.ProductFinding_to_csv.sh
../transform_Oracle_ce.ProductFindingType_to_csv.sh
../transform_Oracle_ce.ProductOpportunityPoints_to_csv.sh
../transform_Oracle_ce.Recommendation_to_csv.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Process S3 Data into CSV Files For Import" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Populate MongoDB Data"
echo "Clinical_Condition"
docker cp ce.ClinicalCondition.csv mongodb_container:/tmp/ce.ClinicalCondition.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c Clinical_Condition --headerline /tmp/ce.ClinicalCondition.csv"
echo "DerivedFact"
docker cp ce.DerivedFact.csv mongodb_container:/tmp/ce.DerivedFact.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c DerivedFact --headerline /tmp/ce.DerivedFact.csv"
echo "DerivedFactProductUsage"
docker cp ce.DerivedFactProductUsage.csv mongodb_container:/tmp/ce.DerivedFactProductUsage.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c DerivedFactProductUsage --headerline /tmp/ce.DerivedFactProductUsage.csv"
echo "MedicalFinding"
docker cp ce.MedicalFinding.csv mongodb_container:/tmp/ce.MedicalFinding.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c MedicalFinding --headerline /tmp/ce.MedicalFinding.csv"
echo "MedicalFindingType"
docker cp ce.MedicalFindingType.csv mongodb_container:/tmp/ce.MedicalFindingType.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c MedicalFindingType --headerline /tmp/ce.MedicalFindingType.csv"
echo "OpportunityPointsDiscr"
docker cp ce.OpportunityPointsDiscr.csv mongodb_container:/tmp/ce.OpportunityPointsDiscr.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c OpportunityPointsDiscr --headerline /tmp/ce.OpportunityPointsDiscr.csv"
echo "ProductFinding"
docker cp ce.ProductFinding.csv mongodb_container:/tmp/ce.ProductFinding.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c ProductFinding --headerline /tmp/ce.ProductFinding.csv"
echo "ProductFindingType"
docker cp ce.ProductFindingType.csv mongodb_container:/tmp/ce.ProductFindingType.csv
docker exec mongodb_container bash -c "mongoimport --type tsv -d ce -c ProductFindingType --headerline /tmp/ce.ProductFindingType.csv"
echo "ProductOpportunityPoints"
docker cp ce.ProductOpportunityPoints.csv mongodb_container:/tmp/ce.ProductOpportunityPoints.csv
docker exec mongodb_container bash -c "mongoimport --type tsv -d ce -c ProductOpportunityPoints --headerline /tmp/ce.ProductOpportunityPoints.csv"
echo "Recommendation"
docker cp ce.Recommendation.csv mongodb_container:/tmp/ce.Recommendation.csv
docker exec mongodb_container bash -c "mongoimport --type csv -d ce -c Recommendation --headerline /tmp/ce.Recommendation.csv"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Populate MongoDB Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 160 -f small "Check MongoDB Locally"
echo "Clinical_Condition"
echo "use ce" > .mongo.js
echo "db.Clinical_Condition.find().limit(2)" >> .mongo.js
echo "db.Clinical_Condition.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "DerivedFact"
echo "use ce" > .mongo.js
echo "db.DerivedFact.find().limit(2)" >> .mongo.js
echo "db.DerivedFact.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "MedicalFinding"
echo "use ce" > .mongo.js
echo "db.MedicalFinding.find().limit(2)" >> .mongo.js
echo "db.MedicalFinding.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "MedicalFindingType"
echo "use ce" > .mongo.js
echo "db.MedicalFindingType.find().limit(2)" >> .mongo.js
echo "db.MedicalFindingType.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "OpportunityPointsDiscr"
echo "use ce" > .mongo.js
echo "db.OpportunityPointsDiscr.find().limit(2)" >> .mongo.js
echo "db.OpportunityPointsDiscr.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "ProductFinding"
echo "use ce" > .mongo.js
echo "db.ProductFinding.find().limit(2)" >> .mongo.js
echo "db.ProductFinding.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "ProductFindingType"
echo "use ce" > .mongo.js
echo "db.ProductFindingType.find().limit(2)" >> .mongo.js
echo "db.ProductFindingType.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "ProductOpportunityPoints"
echo "use ce" > .mongo.js
echo "db.ProductOpportunityPoints.find().limit(2)" >> .mongo.js
echo "db.ProductOpportunityPoints.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
echo "Recommendation"
echo "use ce" > .mongo.js
echo "db.Recommendation.find().limit(2)" >> .mongo.js
echo "db.Recommendation.count()" >> .mongo.js
echo "exit" >> .mongo.js
docker cp .mongo.js mongodb_container:/tmp/.mongo.js
docker exec mongodb_container bash -c "mongo < /tmp/.mongo.js"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "09_MongoDB_Local: Check MongoDB Data" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .mongo.js .results *.csv