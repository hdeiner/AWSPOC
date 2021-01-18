#!/usr/bin/env bash

figlet -w 200 -f small "Test Map/Reduce"
figlet -w 200 -f slant "This is run on AWS ONLY during startup"

source /home/ubuntu/.bash_profile

figlet -w 240 -f small "Start YARN ResourceManager"
start-yarn.sh  # resourcemanager starts correctly for this script, but dies when terraform is done
#yarn resourcemanager 2> /dev/null&
echo "Wait For YARN ResourceManager To Start"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*ResourceManager$")
  if [ $result == 1 ] ; then
#    sleep 10 # give it just a bit more for safety
    echo "YARN ResourceManager has started"
    break
  fi
  sleep 5
done

figlet -w 240 -f small "Start Job History Server"
mapred --daemon start historyserver
echo "Wait For Job History Server To Start"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*JobHistoryServer")
  if [ $result == 1 ] ; then
#    sleep 10 # give it just a bit more for safety
    echo "Job History Server has started"
    break
  fi
  sleep 5
done

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