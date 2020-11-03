#!/usr/bin/env bash

figlet -w 200 -f small "ANTLR Lexer and Parser Generation"
rm -rf antlr-plsql.jar
rm -rf target
mkdir target
rm -rf generated
mkdir generated
java -jar antlr-4.7.1-complete.jar -listener -visitor -Werror -o generated PlSqlLexer.g4
java -jar antlr-4.7.1-complete.jar -listener -visitor -Werror -o generated PlSqlParser.g4

figlet -w 200 -f small "Compile ANTLR Generated Files"
cp PlSqlLexerBase.java generated/.
cp PlSqlParserBase.java generated/.
javac -d target -classpath antlr-4.7.1-complete.jar generated/*.java
jar -cf antlr-plsql.jar target/*