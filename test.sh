#!/bin/bash

# Tests a model to see if it can actually control the AC unit.
#
# You'll probably want to be next to the AC unit to confirm that it is actually turning on and off and changing temperature etc.

API_BASE_URL="https://home.sensibo.com/api/v2/"
# Get these two from shell environment variables, or set it here if you want.
# API_KEY="CHANGE_ME"
# POD="CHANGE_ME"
CURL_ARGS="--silent --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'Accept-Encoding: gzip' --header 'User-Agent: I Am Trying To Find A Vaguely Working AC Model Because The Sensibo App Is Horrible/1.0"
SLEEP_MAX_TIME=60
SLEEP_MIN_TIME=2

MODELCAPABILITIES_PATH=./modelCapabilities/

DESIRED_MODE="cool"
DESIRED_TEMPERATURE=16
DESIRED_TEMPERATURE_UNIT="C"

function usage() {
    local RETURN_CODE=$1
    local MESSAGE=$2
    if [ "${MESSAGE}x" != "x" ] ; then
        echo "${MESSAGE}"
    fi
    echo "Usage: $0 <model>"
    exit $RETURN_CODE
}

MODEL=$1

if [ "${MODEL}x" == "x" ] ; then
    usage 1 "ERROR: Model name not specified"
fi

test -f "${MODELCAPABILITIES_PATH}/${MODEL}.json" || usage 1 "ERROR: Model capabilities file not found: '${MODELCAPABILITIES_PATH}/${MODEL}.json'"

STATUS="429"
while [ "${STATUS}x" != "successx" ] ; do
    # change model
    curl ${CURL_ARGS} -X PUT -d "{\"acModel\":\"${MODEL}\"}" "${API_BASE_URL}pods/${POD}?apiKey=${API_KEY}" 1>result.json
    STATUS=`jq --raw-output '.status' result.json | sed 's/null//g'`
    echo "Model change to '${MODEL}' = ${STATUS}"
    sleep $(( ( RANDOM % ${SLEEP_MAX_TIME} ) + ${SLEEP_MIN_TIME} )) && rm -f result.json
done

STATUS="429"
while [ "${STATUS}x" != "successx" ] ; do
    # turn AC off to desired mode and temperature
    curl ${CURL_ARGS} -X POST -d "{\"acState\": {\"on\":false,\"mode\":\"${DESIRED_MODE}\",\"targetTemperature\":${DESIRED_TEMPERATURE},\"temperatureUnit\": \"${DESIRED_TEMPERATURE_UNIT}\"}}" "${API_BASE_URL}pods/${POD}/acStates?apiKey=${API_KEY}" 1>result.json
    STATUS=`jq --raw-output '.status' result.json | sed 's/null//g'`
    RESULT_STATUS=`jq --raw-output '.result.status' result.json | sed 's/null//g'`
    FAILURE_REASON=`jq --raw-output '.result.failureReason' result.json | sed 's/null//g'`
    echo "Turn AC off = ${STATUS}/${RESULT_STATUS}/${FAILURE_REASON}"
    sleep $(( ( RANDOM % ${SLEEP_MAX_TIME} ) + ${SLEEP_MIN_TIME} )) && rm -f result.json
done

STATUS="429"
while [ "${STATUS}x" != "successx" ] ; do
    # turn AC on to desired mode and temperature
    curl ${CURL_ARGS} -X POST -d "{\"acState\": {\"on\":true,\"mode\":\"${DESIRED_MODE}\",\"targetTemperature\":${DESIRED_TEMPERATURE},\"temperatureUnit\": \"${DESIRED_TEMPERATURE_UNIT}\"}}" "${API_BASE_URL}pods/${POD}/acStates?apiKey=${API_KEY}" 1>result.json
    STATUS=`jq --raw-output '.status' result.json | sed 's/null//g' `
    RESULT_STATUS=`jq --raw-output '.result.status' result.json | sed 's/null//g' `
    FAILURE_REASON=`jq --raw-output '.result.failureReason' result.json | sed 's/null//g' `
    echo "Turn AC on, mode to ${DESIRED_MODE}, temperature to ${DESIRED_TEMPERATURE}${DESIRED_TEMPERATURE_UNIT} = ${STATUS}/${RESULT_STATUS}/${FAILURE_REASON}"
    sleep $(( ( RANDOM % ${SLEEP_MAX_TIME} ) + ${SLEEP_MIN_TIME} )) && rm -f result.json
done

#STATUS="429"
#while [ "${STATUS}x" != "successx" ] ; do
#    # get baseline temperature
#    curl ${CURL_ARGS} "${API_BASE_URL}pods/${POD}?apiKey=${API_KEY}&fields=measurements" 1>result.json
#    STATUS=`jq --raw-output '.status' result.json | sed 's/null//g'`
#    RESULT_STATUS=`jq --raw-output '.result.status' result.json | sed 's/null//g' `
#    FAILURE_REASON=`jq --raw-output '.result.failureReason' result.json | sed 's/null//g' `
#    echo "Get temperature = ${STATUS}/${RESULT_STATUS}/${FAILURE_REASON}"
#done
#
#BASELINE_TEMPERATURE=`jq --raw-output '.result.measurements.temperature' result.json | sed 's/null//g'`
#BASELINE_HUMIDITY=`jq --raw-output '.result.measurements.humidity' result.json | sed 's/null//g'`
#echo "`date`: temperature = ${BASELINE_TEMPERATURE}C, humidity = ${BASELINE_HUMIDITY}%"
#
#for COUNT in `seq 1 10` ; do
#    # get temperature periodically, determine if temperature has dropped indicating that the AC unit is actually on and cooling
#    STATUS="429"
#    while [ "${STATUS}x" != "successx" ] ; do
#        sleep $(( ( RANDOM % 60 ) + ${SLEEP_MIN_TIME} )) && rm -f result.json
#        curl ${CURL_ARGS} "${API_BASE_URL}pods/${POD}?apiKey=${API_KEY}&fields=measurements" 1>result.json
#        STATUS=`jq --raw-output '.status' result.json | sed 's/null//g'`
#        RESULT_STATUS=`jq --raw-output '.result.status' result.json | sed 's/null//g' `
#        FAILURE_REASON=`jq --raw-output '.result.failureReason' result.json | sed 's/null//g' `
#        echo "Get temperature = ${STATUS}/${RESULT_STATUS}/${FAILURE_REASON}"
#    done
#    TEMPERATURE=`jq --raw-output '.result.measurements.temperature' result.json | sed 's/null//g'`
#    HUMIDITY=`jq --raw-output '.result.measurements.humidity' result.json | sed 's/null//g'`
#    TEMPERATURE_DIFF=$(echo "${TEMPERATURE} - ${BASELINE_TEMPERATURE}" | bc)
#    HUMIDITY_DIFF=$(echo "${HUMIDITY} - ${BASELINE_HUMIDITY}" | bc)
#    echo "`date`: temperature = ${TEMPERATURE}C (${TEMPERATURE_DIFF}), humidity = ${HUMIDITY}% (${HUMIDITY_DIFF})"
#
#    if [ ${TEMPERATURE_DIFF} -le -3 ] ; then
#        echo "The correct model to use appears to be '${MODEL}', please test manually using Sensibo app."
#        exit 1
#    fi
#done
#
#rm -f result.json

# EOF
