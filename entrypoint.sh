#!/bin/bash

if [ "$AVD" ]; then
    socat tcp-listen:5555,bind=127.0.0.1,fork tcp:"$AVD" & SOCAT_PID=$!

    echo "Waiting for AVD to become online..."
    while ! adb devices | sed -n 2p | grep -q device; do
        pkill -9 adb
        adb devices > /dev/null
        sleep 10
    done
    echo "AVD is accessible, starting Jenkins Slave"
fi

java -jar /swarm.jar \
    -disableClientsUniqueId \
    -username "$JENKINS_MASTER_USERNAME" \
    -password "$JENKINS_MASTER_PASSWORD" \
    -mode "$JENKINS_SLAVE_MODE" \
    -name "$JENKINS_SLAVE_NAME" \
    -executors "$JENKINS_SLAVE_WORKERS" \
    -master "$JENKINS_MASTER_URL" \
    -fsroot "$JENKINS_SLAVE_ROOT" \
    -labels "$JENKINS_SLAVE_LABELS swarm"

if [ "$AVD_PID" ]; then
    kill $SOCAT_PID
fi
