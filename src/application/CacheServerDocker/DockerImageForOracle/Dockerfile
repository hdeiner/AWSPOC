FROM openjdk:8u242-slim-buster


WORKDIR '/u01/app'

ENV JAVA_OPTS="-ms1024M -mx30720M"


COPY ./libs /u01/app/lib
COPY ./conf /u01/app/conf



# HJD uncommented below, so we don't use wait-for-it
CMD java $JAVA_OPTS -cp conf:lib/* net.ahm.careengine.cecacheserver.CECacheServer
# HJD commented out as per below
#COPY wait-for-it.sh wait-for-it.sh
#RUN chmod +x wait-for-it.sh
# HJD the hostname will have to point to oracle_container at a minimum
# HJD commenting out as we are guarenteed that in a local setting, oracle will be running due to command sequence
# HJD in an AWS setting, we would have to put the terraformed DNS name in here, and the build the image, in which case oracle will have to be running
#CMD ["./wait-for-it.sh" , "oracle:1521" , "--strict" , "--timeout=300" , "--" , "java $JAVA_OPTS -cp conf:lib/* net.ahm.careengine.cecacheserver.CECacheServer"]
