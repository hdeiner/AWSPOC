@echo off
set DEBUG="-agentlib:jdwp=transport=dt_socket,server=y,address=10045,suspend=n"
set NOHUP_FILE=cecachesvr.nohup.out
del/F /Q %NOHUP_FILE%
set GCOPTS="-XX:+UseConcMarkSweepGC -XX:+HeapDumpOnOutOfMemoryError"

%JAVA_HOME%\bin\java -server -d64 -Xms1G -Xmx4G %DEBUG% -cp ..\conf;..\lib\* -Dlog4j.configuration=log4j.properties net.ahm.careengine.cecacheserver.CECacheServer >> %NOHUP_FILE% 2>&1