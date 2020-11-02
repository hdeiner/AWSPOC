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

***01_Postgres_Local***

Runs Postgres in a local Docker container, so we can learn how to handle it when we go to AWS.

***02_PostgreSQL_terraform-aws-rds-aurora-clustered***

Runs PostgreSQL in AWS with cluster capabilities, so we can start collect repeatable metrics about speed, capacity, etc. for this database engine.

***03_MySQL_Local***

Runs MySQL in a local Docker container, so we can learn how to handle it when we go to AWS.

***04_MySQL_terraform-aws-rds-aurora-clustered***

Runs MySQL in AWS with cluster capabilities, so we can start collect repeatable metrics about speed, capacity, etc. for this database engine.

***05_Cassandra_Local***

Runs Cassandra in a local Docker container, so we can learn how to handle it when we go to AWS.

***06_Cassandra_AWS***

Runs Cassandra in an AWS EC2 instance, so we can start collect repeatable metrics about speed, capacity, etc. for this database engine.

***07_Oracle_Local***

Runs Oracle in a local Docker container, so we can learn how to handle it when we go to AWS.  We will want to show the difference in performance between Oracle and the other databases under consideration.

***08_Oracle_AWS***

Runs Oracle in an AWS EC2 instance, so we can start collect repeatable metrics about speed, capacity, etc. for this database engine.  We will want to show the difference in performance between Oracle and the other databases under consideration.
