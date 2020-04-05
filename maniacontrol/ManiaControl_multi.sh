#!/bin/sh

echo "ManiaControl_multi.sh [INFO] - Start"
# Make sure we use defaults everywhere.
: ${MANIACONTROL_CONFIG_FILE:="server.default.xml"}

echo "ManiaControl_multi.sh [INFO] - MANIACONTROL_CONFIG_FILE = ${MANIACONTROL_CONFIG_FILE}"

ITERATION_NUMBER=10
NUMBER_OF_SECOND_PER_ITERATION=1
for i in `seq 1 ${ITERATION_NUMBER}`;
do
    echo "ManiaControl_multi.sh [INFO] - Wait for 1 sec than server is open - ${i} / ${ITERATION_NUMBER}"
    sleep ${NUMBER_OF_SECOND_PER_ITERATION}
done

php ManiaControl.php -config=${MANIACONTROL_CONFIG_FILE} >./logs/ManiaControl.log 2>&1
# echo $! > ./logs/ManiaControl.pid

echo "ManiaControl_multi.sh [INFO] - End"
