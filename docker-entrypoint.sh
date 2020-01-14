#!/bin/bash


#echo environment variables
env

set -ex

APP_PID="/content-engine.pid"
APP_HOST=`hostname -f`

if [[ ${TRACK} == "prod-singapore" ]]
then
    newrelic="-J-javaagent:/app/conf/newrelic/newrelic.jar"
else
    newrelic=""
fi

exec /app/bin/contentengine -Dfile.encoding=UTF-8 -Dconfig.file=/app/conf/mt.conf -Dlogger.file=/app/conf/logger.xml -Djdk.tls.rejectClientInitiatedRenegotiation=true -Djdk.tls.ephemeralDHKeySize=2048 -J-Xms${JVM_HEAP_SIZE} -J-Xmx${JVM_HEAP_SIZE} -Dhttp.port=${PORT} -Dpidfile.path=${APP_PID} -Dapp.host=${APP_HOST} ${newrelic}

set +ex