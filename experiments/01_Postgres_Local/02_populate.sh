#!/usr/bin/env bash

figlet -w 160 -f small "Populate Postgres Locally"
docker exec postgres_container psql --port=5432 --username=postgres --no-password --no-align -c 'create database testdatabase;'
liquibase update  ## WE NEED TO COPY THE changeset.oracle.xml over changeset.xml, as we don't want to use the automatic data loading anymore

../../data/transfer_from_s3_and_decrypt.sh ce.Clinical_Condition.csv

../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFact.csv
docker cp ce.DerivedFact.csv postgres_container:/tmp/ce.DerivedFact.csv
docker exec postgres_container psql --port=5432 --username=postgres --no-password --no-align -d testdatabase -c "COPY DERIVEDFACT(DERIVEDFACTID,DERIVEDFACTTRACKINGID,DERIVEDFACTTYPEID,INSERTEDBY,RECORDINSERTDT,RECORDUPDTDT,UPDTDBY) FROM '/tmp/ce.DerivedFact.csv' DELIMITER '|' CSV HEADER;"

../../data/transfer_from_s3_and_decrypt.sh ce.DerivedFactProductUsage.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.MedicalFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.OpportunityPointsDiscr.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFinding.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductFindingType.csv
../../data/transfer_from_s3_and_decrypt.sh ce.ProductOpportunityPoints.csv
../../data/transfer_from_s3_and_decrypt.sh ce.Recommendation.csv

rm *.csv

figlet -w 160 -f small "Check Postgres Locally"
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d testdatabase --no-align -c 'select * from DERIVEDFACT limit 10;'
docker exec postgres_container psql --port=5432 --username=postgres --no-password -d testdatabase --no-align -c 'select count(*) from DERIVEDFACT;'
#docker exec postgres_container psql --port=5432 --username=postgres --no-password -d testdatabase --no-align -c 'select * from MEMBERHEALTHSTATE;'