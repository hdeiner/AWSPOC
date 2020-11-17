#!/usr/bin/env bash

figlet -w 200 -f slant "This is run on AWS ONLY during startup"
cd /tmp

figlet -w 160 -f small "Get Data from S3 Bucket"
./transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv
./transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
./transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
./transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
./transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
./transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
./transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
./transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
./transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
./transfer_from_s3_and_decrypt.sh ce.Recommendation.csv

figlet -w 160 -f small "Populate MongoDB AWS"

echo "Clinical_Condition"
# add header
sed -i '1 i\CLINICAL_CONDITION_COD|CLINICAL_CONDITION_NAM|INSERTED_BY|REC_INSERT_DATE|REC_UPD_DATE|UPDATED_BY|CLINICALCONDITIONCLASSCD|CLINICALCONDITIONTYPECD|CLINICALCONDITIONABBREV' ce.Clinical_Condition.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.Clinical_Condition.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.Clinical_Condition.csv
# get rid of timestamps
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+//g' ce.Clinical_Condition.csv
# get rid of ^M (return characters)
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.Clinical_Condition.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Clinical_Condition.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Clinical_Condition.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.Clinical_Condition.csv
tr -d $'\r' < ce.Clinical_Condition.csv > ce.Clinical_Condition.csv.mod
mongoimport --type csv -d testdatabase -c Clinical_Condition --headerline /tmp/ce.Clinical_Condition.csv.mod

echo "DerivedFact"
# add header
sed -i '1 i\DERIVEDFACTID|DERIVEDFACTTRACKINGID|DERIVEDFACTTYPEID|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.DerivedFact.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.DerivedFact.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.DerivedFact.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.DerivedFact.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.DerivedFact.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.DerivedFact.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.DerivedFact.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.DerivedFact.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.DerivedFact.csv > ce.DerivedFact.csv.mod
mongoimport --type csv -d testdatabase -c DerivedFact --headerline ce.DerivedFact.csv.mod

echo "DerivedFactProductUsage"
# add header
sed -i '1 i\DERIVEDFACTPRODUCTUSAGEID|DERIVEDFACTID|PRODUCTMNEMONICCD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.DerivedFactProductUsage.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.DerivedFactProductUsage.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.DerivedFactProductUsage.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.DerivedFactProductUsage.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.DerivedFactProductUsage.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.DerivedFactProductUsage.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.DerivedFactProductUsage.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.DerivedFactProductUsage.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.DerivedFactProductUsage.csv > ce.DerivedFactProductUsage.csv.mod
mongoimport --type csv -d testdatabase -c DerivedFactProductUsage --headerline ce.DerivedFactProductUsage.mod

echo "MedicalFinding"
# add header
sed -i '1 i\MEDICALFINDINGID|MEDICALFINDINGTYPECD|MEDICALFINDINGNM|SEVERITYLEVELCD|IMPACTABLEFLG|CLINICAL_CONDITION_COD|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|ACTIVEFLG|OPPORTUNITYPOINTSDISCRCD' ce.MedicalFinding.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.MedicalFinding.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.MedicalFinding.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.MedicalFinding.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.MedicalFinding.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.MedicalFinding.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.MedicalFinding.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.MedicalFinding.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.MedicalFinding.csv > ce.MedicalFinding.csv.mod
mongoimport --type csv -d testdatabase -c MedicalFinding --headerline ce.MedicalFinding.csv.mod

echo "MedicalFindingType"
# add header
sed -i '1 i\MEDICALFINDINGTYPECD|MEDICALFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY|HEALTHSTATEAPPLICABLEFLAG' ce.MedicalFindingType.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.MedicalFindingType.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.MedicalFindingType.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.MedicalFindingType.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.MedicalFindingType.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.MedicalFindingType.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.MedicalFindingType.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.MedicalFindingType.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.MedicalFindingType.csv > ce.MedicalFindingType.csv.mod
mongoimport --type csv -d testdatabase -c MedicalFinding --headerline ce.MedicalFindingType.csv.mod

echo "OpportunityPointsDiscr"
# add header
sed -i '1 i\OPPORTUNITYPOINTSDISCRCD|OPPORTUNITYPOINTSDISCNM|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.OpportunityPointsDiscr.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.OpportunityPointsDiscr.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.OpportunityPointsDiscr.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.OpportunityPointsDiscr.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.OpportunityPointsDiscr.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.OpportunityPointsDiscr.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.OpportunityPointsDiscr.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.OpportunityPointsDiscr.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.OpportunityPointsDiscr.csv > ce.OpportunityPointsDiscr.csv.mod
mongoimport --type csv -d testdatabase -c OpportunityPointsDiscr --headerline ce.OpportunityPointsDiscr.csv.mod

echo "ProductFinding"
# add header
sed -i '1 i\PRODUCTFINDINGTYPECD|PRODUCTFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductFinding.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductFinding.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductFinding.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductFinding.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductFinding.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductFinding.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductFinding.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductFinding.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.ProductFinding.csv > ce.ProductFinding.csv.mod
mongoimport --type csv -d testdatabase -c ProductFinding --headerline ce.ProductFinding.csv.mod

echo "ProductFindingType"
# add header
sed -i '1 i\PRODUCTFINDINGTYPECD|PRODUCTFINDINGTYPEDESC|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductFindingType.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductFindingType.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductFindingType.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductFindingType.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductFindingType.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductFindingType.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductFindingType.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductFindingType.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.ProductFindingType.csv > ce.ProductFindingType.csv.mod
mongoimport --type csv -d testdatabase -c ProductFindingType --headerline ce.ProductFindingType.csv.mod

echo "ProductOpportunityPoints"
# add header
sed -i '1 i\OPPORTUNITYPOINTSDISCCD|EFFECTIVESTARTDT|OPPORTUNITYPOINTSNBR|EFFECTIVEENDDT|DERIVEDFACTPRODUCTUSAGEID|INSERTEDBY|RECORDINSERTDT|RECORDUPDTDT|UPDTDBY' ce.ProductOpportunityPoints.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ProductOpportunityPoints.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ProductOpportunityPoints.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ProductOpportunityPoints.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ProductOpportunityPoints.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ProductOpportunityPoints.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ProductOpportunityPoints.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ProductOpportunityPoints.csv
# get rid of ^M (return characters)
tr -d $'\r' < ce.ProductOpportunityPoints.csv > ce.ProductOpportunityPoints.csv.mod
mongoimport --type csv -d testdatabase -c ProductOpportunityPoints --headerline ce.ProductOpportunityPoints.csv.mod

echo "Recommendation"
# get rid of ^M (return characters)
tr -d $'\r' < ce.Recommendation.csv > ce.Recommendation.csv.mod
# Merge every other line in ce.Recommendation together with a comma between them
paste - - - -d'|' < ce.Recommendation.csv.mod > ce.Recommendation.csv
# add header
sed -i '1 i\RECOMMENDATIONSKEY|RECOMMENDATIONID|RECOMMENDATIONCODE|RECOMMENDATIONDESC|RECOMMENDATIONTYPE|CCTYPE|CLINICALREVIEWTYPE|AGERANGEID|ACTIONCODE|THERAPEUTICCLASS|MDCCODE|MCCCODE|PRIVACYCATEGORY|INTERVENTION|RECOMMENDATIONFAMILYID|RECOMMENDPRECEDENCEGROUPID|INBOUNDCOMMUNICATIONROUTE|SEVERITY|PRIMARYDIAGNOSIS|SECONDARYDIAGNOSIS|ADVERSEEVENT|ICMCONDITIONID|WELLNESSFLAG|VBFELIGIBLEFLAG|COMMUNICATIONRANKING|PRECEDENCERANKING|PATIENTDERIVEDFLAG|LABREQUIREDFLAG|UTILIZATIONTEXTAVAILABLEF|SENSITIVEMESSAGEFLAG|HIGHIMPACTFLAG|ICMLETTERFLAG|REQCLINICIANCLOSINGFLAG|OPSIMPELMENTATIONPHASE|SEASONALFLAG|SEASONALSTARTDT|SEASONALENDDT|EFFECTIVESTARTDT|EFFECTIVEENDDT|RECORDINSERTDT|RECORDUPDTDT|INSERTEDBY|UPDTDBY|STANDARDRUNFLAG|INTERVENTIONFEEDBACKFAMILYID|CONDITIONFEEDBACKFAMILYID|ASHWELLNESSELIGIBILITYFLAG|HEALTHADVOCACYELIGIBILITYFLAG' ce.Recommendation.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.Recommendation.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.Recommendation.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.Recommendation.csv
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.Recommendation.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.Recommendation.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.Recommendation.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.Recommendation.csv
cp ce.Recommendation.csv ce.Recommendation.csv.mod
mongoimport --type csv -d testdatabase -c Recommendation --headerline ce.Recommendation.csv.mod

figlet -w 160 -f small "Check MongoDB AWS"
echo ""
echo "Clinical_Condition"
echo 'use testdatabase' > .mongo.js
echo 'db.Clinical_Condition.find().limit(2)' >> .mongo.js
echo 'db.Clinical_Condition.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "DerivedFact"
echo 'use testdatabase' > .mongo.js
echo 'db.DerivedFact.find().limit(2)' >> .mongo.js
echo 'db.DerivedFact.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "MedicalFinding"
echo 'use testdatabase' > .mongo.js
echo 'db.MedicalFinding.find().limit(2)' >> .mongo.js
echo 'db.MedicalFinding.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "MedicalFindingType"
echo 'use testdatabase' > .mongo.js
echo 'db.MedicalFindingType.find().limit(2)' >> .mongo.js
echo 'db.MedicalFindingType.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "OpportunityPointsDiscr"
echo 'use testdatabase' > .mongo.js
echo 'db.OpportunityPointsDiscr.find().limit(2)' >> .mongo.js
echo 'db.OpportunityPointsDiscr.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "ProductFinding"
echo 'use testdatabase' > .mongo.js
echo 'db.ProductFinding.find().limit(2)' >> .mongo.js
echo 'db.ProductFinding.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "ProductFindingType"
echo 'use testdatabase' > .mongo.js
echo 'db.ProductFindingType.find().limit(2)' >> .mongo.js
echo 'db.ProductFindingType.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "ProductOpportunityPoints"
echo 'use testdatabase' > .mongo.js
echo 'db.ProductOpportunityPoints.find().limit(2)' >> .mongo.js
echo 'db.ProductOpportunityPoints.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

echo ""
echo "Recommendation"
echo 'use testdatabase' > .mongo.js
echo 'db.Recommendation.find().limit(2)' >> .mongo.js
echo 'db.Recommendation.count()' >> .mongo.js
echo 'exit' >> .mongo.js
mongo < .mongo.js

rm .mongo.js *.csv *.mod

cd -
