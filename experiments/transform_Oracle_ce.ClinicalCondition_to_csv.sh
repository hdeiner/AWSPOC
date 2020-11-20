#!/usr/bin/env bash

echo "ClinicalCondition"
# add header
sed -i '1 i\CLINICAL_CONDITION_COD|CLINICAL_CONDITION_NAM|INSERTED_BY|REC_INSERT_DATE|REC_UPD_DATE|UPDATED_BY|CLINICALCONDITIONCLASSCD|CLINICALCONDITIONTYPECD|CLINICALCONDITIONABBREV' ce.Clinical_Condition.csv
# convert comas to semi-colons
sed --in-place --regexp-extended 's/,/;/g' ce.ClinicalCondition.csv
# convert bars to commas
sed --in-place 's/|/,/g' ce.ClinicalCondition.csv
# get rid of timestamps and decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+\.[0-9]+//g' ce.ClinicalCondition.csv
# get rid of timestamps without decimals after timestamp
sed --in-place --regexp-extended 's/ [0-9]+[0-9]+\:[0-9]+[0-9]+\:[0-9]+//g' ce.ClinicalCondition.csv
# get rid of ^M (return characters)
# remove blanks at start of line
sed --in-place --regexp-extended 's/^ *//g' ce.ClinicalCondition.csv
# remove blanks before commas
sed --in-place --regexp-extended 's/[ ]+,/,/g' ce.ClinicalCondition.csv
# remove blanks after commas
sed --in-place --regexp-extended 's/,[ ]+/,/g' ce.ClinicalCondition.csv
# remove blanks at end of line
sed --in-place --regexp-extended 's/ *$//g' ce.ClinicalCondition.csv
tr -d $'\r' < ce.Clinical_Condition.csv > ce.ClinicalCondition.csv.mod
cp ce.ClinicalCondition.csv.mod ce.ClinicalCondition.csv
rm ce.ClinicalCondition.csv.mod
