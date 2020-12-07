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

figlet -w 240 -f small "Populate PostgreSQL Clustered on AWS RDS Aurora - Large Data - $(numfmt --grouping $ROWS) rows"

figlet -w 240 -f small "Populate PostgreSQL Clustered on AWS RDS Aurora"
echo `terraform output database_dns | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_dns
echo `terraform output database_port | grep -Eo '"'"'[0-9]{1,}'"'"' | cut -d '"'"'"'"'"' -f2` > .database_port
echo `terraform output database_username | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_username
echo `terraform output database_password | grep -o '"'"'".*"'"'"' | cut -d '"'"'"'"'"' -f2` > .database_password

cp .database_dns .database_name
sed --in-place --regexp-extended '"'"'s/\..*//g'"'"' .database_name

figlet -w 240 -f small "Apply Schema for Postgres - Large Data - $(numfmt --grouping $ROWS) rows"
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);echo \"create database PGYR19_P063020;\" | psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password  --no-align"
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);echo \"create schema PI;\" | psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d pgyr19_p063020 --no-align"
liquibase --changeLogFile=../../ddl/PGYR19_P063020/changeset.xml --url=jdbc:postgresql://$(<.database_dns):$(<.database_port)/pgyr19_p063020 --username=$(<.database_username) --password=$(<.database_password)  --driver=org.postgresql.Driver --classpath=../../liquibase_drivers/postgresql-42.2.18.jre6.jar update
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "02_PostgreSQL_AWS_Clustered: Populate Postgres Schema - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Get Data from S3 Bucket"
../../data/transferPGYR19_P063020_from_s3_and_decrypt.sh
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "02_PostgreSQL_AWS_Clustered: Get Data from S3 Bucket - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm .script .results Experimental\ Results.csv
ls -lh /tmp/PGYR19_P063020

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Populate Postgres Data - Large Data - $ROWS rows"
head -n `echo $ROWS+1 | bc` /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.csv > /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place 's/applicable_manufacturer_or_applicable_gpo_making_payment_country/applicable_manufacturer_or_applicable_gpo_making_payment_countr/gI' /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
sed --in-place 's/name_of_third_party_entity_receiving_payment_or_transfer_of_value/name_of_third_party_entity_receiving_payment_or_transfer_of_val/gI' /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
COLUMN_NAMES=$(head -n 1 /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv)
docker cp /tmp/PGYR19_P063020/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv postgres_container:/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);echo \"\COPY PI.OP_DTL_GNRL_PGYR2019_P06302020("$COLUMN_NAMES") FROM '"'"'/tmp/OP_DTL_GNRL_PGYR2019_P06302020.subset.csv'"'"' DELIMITER '"'"','"'"' CSV HEADER;\" | psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d pgyr19_p063020 --no-align"
EOF'
chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "02_PostgreSQL_AWS_Clustered: Populate Postgres Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .results Experimental\ Results.csv

bash -c 'cat << "EOF" > .script
#!/usr/bin/env bash
figlet -w 240 -f small "Check Postgres Data - Large Data - $(numfmt --grouping $ROWS) rows"
echo ""
echo "First two rows of data"
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d pgyr19_p063020 --no-align -c '"'"'select * from PI.OP_DTL_GNRL_PGYR2019_P06302020 limit 2;'"'"'"
echo ""
echo "Count of rows of data"
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d pgyr19_p063020 --no-align -c '"'"'select count(*) from PI.OP_DTL_GNRL_PGYR2019_P06302020;'"'"'"
echo ""
echo "Average of total_amount_of_payment_usdollars"
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d pgyr19_p063020 --no-align -c '"'"'select avg(total_amount_of_payment_usdollars) from PI.OP_DTL_GNRL_PGYR2019_P06302020;'"'"'"
echo ""
echo "Top ten earning physicians"
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars), COUNT(total_amount_of_payment_usdollars)" > .sql
echo "FROM PI.OP_DTL_GNRL_PGYR2019_P06302020" >> .sql
echo "WHERE physician_first_name IS NOT NULL" >> .sql
echo "  AND physician_last_name IS NOT NULL" >> .sql
echo "GROUP BY physician_first_name, physician_last_name" >> .sql
echo "ORDER BY SUM(total_amount_of_payment_usdollars) DESC" >> .sql
echo "LIMIT 10;" >> .sql
export QUERY=$(<.sql)
docker exec postgres_container bash -c "export PGPASSWORD=$(<.database_password);psql --host=$(<.database_dns) --port=$(<.database_port) --username=$(<.database_username) --no-password -d pgyr19_p063020 --no-align -c '"'"'$QUERY'"'"'"
EOF'

chmod +x .script
command time -v ./.script 2> .results
../../getExperimentalResults.sh
experiment=$(../../getExperimentNumber.sh)
../../getDataAsCSVline.sh .results ${experiment} "02_PostgreSQL_AWS_Clustered: Check Postgres Data - Large Data - $ROWS rows" >> Experimental\ Results.csv
../../putExperimentalResults.sh
rm -rf .script .sql .results *.csv /tmp/PGYR19_P063020 .database_dns .database_port .database_name .database_username .database_password