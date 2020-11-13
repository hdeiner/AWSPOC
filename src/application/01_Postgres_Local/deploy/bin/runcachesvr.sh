#!/bin/sh

opnet=`echo $@ | grep -c OPNET`
if [ ${opnet} -gt 0 ]
 then
   opnet="-agentpath:/opt/Panorama/hedzup/mn/lib/librpilj64.so"
else
   opnet=""
fi

if [ -n "$1" ]
then
    if [ "$1" = "debug" ]
    then
        debug="-agentlib:jdwp=transport=dt_socket,server=y,address=10065,suspend=n"
    fi
fi

NOHUP_FILE=cecachesvr.nohup.out
rm -f ${NOHUP_FILE} >/dev/null 2>&1

#CLASSPATH=../conf:../lib/*
CLASSPATH=../conf:../../../shared_libs/*

echo "CLASSPATH:$CLASSPATH" >> ${NOHUP_FILE}
gcopts="-XX:+UseConcMarkSweepGC -XX:+HeapDumpOnOutOfMemoryError"
ORACLE_ISSUE_OPTS=-Djava.security.egd=file:///dev/urandom
echo "JAVA_HOME : $JAVA_HOME" >> ${NOHUP_FILE}
nohup $JAVA_HOME/bin/java -server -ms1024M -mx30720M $debug -cp $CLASSPATH -Dlog4j.configuration=log4j.properties $opnet $gcopts $ORACLE_ISSUE_OPTS net.ahm.careengine.cecacheserver.CECacheServer >> ${NOHUP_FILE} 2>&1 &
