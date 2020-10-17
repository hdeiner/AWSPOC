# HealthEngineAWSPOC

Root level folder structure is explained below.

**OracleSchemas**

This folder contains all the scripts generated as it is from our Oracle platform. It is organized with the existing schema names so that the users can easily identify the source. For example, everything under the folder *CSID* means they were exported from the CSID schema.

Under the folder representing the schema, the file name is organized based on the original table name. For example, ELEMENT.sql under *ODS* is the DDL generated based on the actual table ELEMENT from the *ODS* schema from the Oracle platform.

Under this POC, we are working on the following schemas:

- CSID
- ODS
- CE

**experiments**

This is where we share knowledge about how to do something or answer other questions related to the project.  We don't want to lose the organizational knowledge to the ether.

***Postgres_Local***

Runs Postgres in a local Docker container, so we can learn how to handle it when we go to AWS.

****01_startup.sh****

Uses docker-compose to create a Postgres container.  Wait for the container's logs to indicate that the database is ready to accept connections.

****02_populate.sh****

Uses psql from the container to create a database, creates the schema using Liquibase, and then uses psql to demonstrate that the schema is present in the database.

****03_shutdown.sh****

Uses docker-compose to bring down the container started in 01_startuo.sh.

***PostgreSQL_terraform-aws-rds-aurora***

Runs PostgreSQL in AWS with cluster capabilities, so we can start collect repeatable metrics about speed, capacity, etc. for this database engine.

****01_startup.sh****

Uses terraform to create the AWS objects.  

****02_populate.sh****

Uses locally installed psql to create a database, creates the schema using Liquibase (liquibase.properties is dynamically generated), and then uses psql to demonstrate that the schema is present in the database.

****03_shutdown.sh****

Uses terraform to destroy all of the AWS objects created in 01_startup.sh.