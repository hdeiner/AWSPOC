#!/usr/bin/env bash

figlet -w 200 -f small "ANTLR Lexer and Parser Generation"
rm -rf generated
mkdir generated
java -jar antlr-4.7.1-complete.jar -listener -visitor -Werror -package Translator -o generated PlSqlLexer.g4
java -jar antlr-4.7.1-complete.jar -listener -visitor -Werror -package Translator -o generated PlSqlParser.g4

figlet -w 200 -f small "Create PlSqlTranslator"
#mvn install:install-file -Dfile=antlr-4.7.1-complete.jar -DgroupId=org.antlr -DartifactId=antlr -Dpackaging=jar -Dversion=4.7.1-complete
mvn clean compile
cp antlr-4.7.1-complete.jar target/classes/.
cd target/classes/
jar -xf antlr-4.7.1-complete.jar
rm -rf antlr-4.7.1-complete.jar
cd ../..
mvn  package

figlet -w 200 -f small "Run PlSqlTranslator"
#java -jar target/PlSqlTranslator-1.0-SNAPSHOT.jar $PWD/../examples/create_table.sql
java -jar target/PlSqlTranslator-1.0-SNAPSHOT.jar $PWD/../examples-sql-script/anonymous_block.sql

rm -rf generated target