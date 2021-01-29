#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Test Map/Reduce$(tput sgr 0)"
echo "$(tput bold)$(tput smul)$(tput setaf 6)This is run on AWS ONLY during startup$(tput sgr 0)"

source /home/ubuntu/.bash_profile

cd /tmp

export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

echo "time flies like an arrow" | tee file01
echo "fruit flies like a banana" | tee file02
echo "Rose rose to put rose roes on her rows of roses" | tee file03

hdfs dfs -mkdir -p /usr/joe/wordcount/input
hdfs dfs -put file01 /usr/joe/wordcount/input/file01
hdfs dfs -put file02 /usr/joe/wordcount/input/file02
hdfs dfs -put file03 /usr/joe/wordcount/input/file03

hadoop jar wc.jar WordCount /usr/joe/wordcount/input /usr/joe/wordcount/output 2> /dev/null

hdfs dfs -cat /usr/joe/wordcount/output/part-r-00000
hdfs dfs -copyToLocal /usr/joe/wordcount/output/part-r-00000 mr.txt

sed --in-place 's/\t/ /g' mr.txt

echo "Rose 1" > mr.answer
echo "a 1" >> mr.answer
echo "an 1" >> mr.answer
echo "arrow 1" >> mr.answer
echo "banana 1" >> mr.answer
echo "flies 2" >> mr.answer
echo "fruit 1" >> mr.answer
echo "her 1" >> mr.answer
echo "like 2" >> mr.answer
echo "of 1" >> mr.answer
echo "on 1" >> mr.answer
echo "put 1" >> mr.answer
echo "roes 1" >> mr.answer
echo "rose 2" >> mr.answer
echo "roses 1" >> mr.answer
echo "rows 1" >> mr.answer
echo "time 1" >> mr.answer
echo "to 1" >> mr.answer

result=$(diff mr.txt mr.answer | wc -l)
if [ $result == 0 ] ; then
  echo "$(tput bold)$(tput setaf 2)Test Map/Reduce SUCCESS$(tput sgr 0)"
else
  echo "$(tput bold)$(tput setaf 2)Test Map/Reduce FAILURE$(tput sgr 0)"
fi
