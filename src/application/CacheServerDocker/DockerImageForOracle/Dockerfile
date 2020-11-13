FROM openjdk:8u242-slim-buster


WORKDIR '/u01/app'

ENV JAVA_OPTS="-ms1024M -mx30720M"


COPY ./libs /u01/app/lib
COPY ./conf /u01/app/conf

COPY wait-for-it.sh wait-for-it.sh 
RUN chmod +x wait-for-it.sh

#CMD java $JAVA_OPTS -cp conf:lib/* net.ahm.careengine.cecacheserver.CECacheServer
CMD ["./wait-for-it.sh" , "oracle:1521" , "--strict" , "--timeout=300" , "--" , "java $JAVA_OPTS -cp conf:lib/* net.ahm.careengine.cecacheserver.CECacheServer"]
