#!/usr/bin/env bash

figlet -w 200 -f small "ANTLR Lexer and Parser Generation For Ignite"
#rm -rf PlSqlIgniteTranslator-1.0-SNAPSHOT.jar
#rm -rf target
#mkdir target
rm -rf generated
mkdir generated
java -jar antlr-4.7.1-complete.jar -listener -visitor -Werror -package Translator -o generated PlSqlLexer.g4
java -jar antlr-4.7.1-complete.jar -listener -visitor -Werror -package Translator -o generated PlSqlParser.g4

figlet -w 200 -f small "Create PlSqlIgniteTranslator"
#mvn install:install-file -Dfile=antlr-4.7.1-complete.jar -DgroupId=org.antlr -DartifactId=antlr -Dpackaging=jar -Dversion=4.7.1-complete
mvn clean compile
cp antlr-4.7.1-complete.jar target/classes/.
cd target/classes/
jar -xf antlr-4.7.1-complete.jar
rm -rf antlr-4.7.1-complete.jar
cd ../..
mvn  package

figlet -w 200 -f small "Run PlSqlCassandraTranslator"
#java -jar target/PlSqlIgniteTranslator-1.0-SNAPSHOT.jar $PWD/../examples/create_table.sql
java -jar target/PlSqlIgniteTranslator-1.0-SNAPSHOT.jar $PWD/./ddl.sql

rm -rf generated target