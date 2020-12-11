#!/usr/bin/env bash

ROWS=$1

figlet -w 240 -f small "Populate MySQL Data - Large Data - $ROWS rows"
head -n `echo "$ROWS+1" | bc` /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country/Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place s/Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value/Name_of_Third_Party_Entity_Receiving_Payment_or_transfer_of_Val/g /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
head -n 1 /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv > .columns
sed --in-place -e 's/Teaching_Hospital_ID,/@Teaching_Hospital_ID,/' .columns
sed --in-place -e 's/Date_of_Payment,/@Date_of_Payment,/' .columns
sed --in-place -e 's/Payment_Publication_Date/@Payment_Publication_Date/' .columns
sed --in-place -e 's/Physician_Profile_ID/@Physician_Profile_ID/' .columns

echo 'LOAD DATA LOCAL INFILE '\''/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv'\'' ' > .command
echo ' INTO TABLE PI.OP_DTL_GNRL_PGYR2019_P06302020 ' >> .command
echo ' FIELDS TERMINATED BY '\'\,\'' ' >> .command
echo ' OPTIONALLY ENCLOSED BY '\'\"\'' ' >> .command
echo ' LINES TERMINATED BY '\'\\\n\'' ' >> .command
echo ' IGNORE 1 ROWS' >> .command
echo ' ('$(<.columns)') ' >> .command
echo ' SET Teaching_Hospital_ID = IF(@Teaching_Hospital_ID='\'\'',-1,@Teaching_Hospital_ID), ' >> .command
echo '     Date_of_Payment = STR_TO_DATE(@Date_of_Payment,'\'%m/%d/%Y\''), ' >> .command
echo '     Payment_Publication_Date = STR_TO_DATE(@Payment_Publication_Date,'\'%m/%d/%Y\''), ' >> .command
echo '     Physician_Profile_ID = IF(@Physician_Profile_ID='\'\'',-1,@Physician_Profile_ID); ' >> .command
docker cp /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv mysql_container:/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
docker exec mysql_container mysql -h $(<.database_dns) -P $(<.database_port) -u $(<.database_username) --password=$(<.database_password) PI --local-infile --execute "$(<.command)"
rm .columns .command
