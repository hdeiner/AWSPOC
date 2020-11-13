#!/bin/sh

CLASSPATH=.:../lib/*;

host=""
port=""
cache=""
error=""

while true; do
   case "$1" in
      -h) host="$2"; shift 2;;
      -p) port="$2"; shift 2;;
      -c) cache="$2"; shift 2;;
      *)  break;;
   esac
done

if [[ "${host}" = "" || "${port}" = "" || "${cache}" = "" ]]; then
    error="yes"
fi

if [ -v $JAVA_HOME ];
then
    echo "JAVA_HOME is not set, exiting..."
    exit -1;
fi

if [[ "${cache}" != "all" 
	&& "${cache}" != "provider" 
	&& "${cache}" != "accountpackage" 
	&& "${cache}" != "admin" 
	&& "${cache}" != "rule" 
	&& "${cache}" != "supplier" 
	&& "${cache}" != "healthstate" 
	&& "${cache}" != "providerspeciality"
        && "${cache}" != "car"
        && "${cache}" != "providerextract"
	&& "${cache}" != "memberextract" ]]; then
    error="yes"
fi

if [[ "${error}" = "yes" ]]; then
    echo "Usage flushcache -h <host> -p <port> -c <cache>"
    echo "  where"
    echo "    host - hostname of the cache server"
    echo "    port - rmi port the cache service are exposed"
    echo "    cache - cache to flush"
    echo "        all - flushes all the cache"
    echo "        provider - flushes only provider cache"
    echo "        accountpackage - flushes only account package cache"
    echo "        admin - flushes only admin cache"
    echo "        rule - flushes only rule cache"
    echo "        supplier - flushes only supplier cache"
    echo "        healthstate - flushes only health state cache"
    echo "        providerspeciality - flushes only speciality cache"
    echo "        car - flushes only Clinical Analytics Reporting related cache"
    echo "        cepm extract provider - flushes only cepm extract provider cache"
    echo "        cepm extract member - flushes only cepm extract provider cache"
    echo "(ex) flushcache -h localhost -p 1299 -c all"
    exit 1
fi

echo "Flushing CacheServer at Host - ${host}, Port - ${port}, Cache - ${cache}"

$JAVA_HOME/bin/java -cp $CLASSPATH  net.ahm.careengine.cecacheclient.CECacheFlush $host $port $cache

