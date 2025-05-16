#!/bin/bash

# Gets the capabilities for all known models and stores them in the modelCapabilities directory.

API_BASE_URL="https://home.sensibo.com/api/v2/"
# Get these two from shell environment variables, or set it here if you want.
# API_KEY="CHANGE_ME"
# POD="CHANGE_ME"
CURL_ARGS="--silent --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'Accept-Encoding: gzip' --header 'User-Agent: I Am Trying To Find A Vaguely Working AC Model Because The Sensibo App Is Horrible/1.0"
SLEEP_MAX_TIME=60
SLEEP_MIN_TIME=10

# migrate to pulling this live?
jq '.result.brands[][]' --raw-output models.json > models.txt
input="models.txt"

while IFS= read -r MODEL
do
  echo "Getting model: $MODEL"

  STATUS="429"
  while [ "${STATUS}x" == "429x" ] ; do
    # change model
    curl ${CURL_ARGS} -X PUT -d "{\"acModel\":\"${MODEL}\"}" "${API_BASE_URL}pods/${POD}?apiKey=${API_KEY}" 1>result.json
    STATUS=`jq --raw-output '.status' result.json | sed 's/null//g'`
    echo "Model change = ${STATUS}"
    sleep $(( ( RANDOM % ${SLEEP_MAX_TIME} ) + ${SLEEP_MIN_TIME} )) && rm -f result.json
  done

  if [ "${STATUS}x" == "successx" ] ; then
    STATUS="429"
    while [ "${STATUS}x" != "successx" ] ; do
      curl ${CURL_ARGS} "${API_BASE_URL}pods/${POD}?apiKey=${API_KEY}&fields=*" 1>result.json
      STATUS=`jq --raw-output '.status' result.json | sed 's/null//g'`
      RESULT_STATUS=`jq --raw-output '.result.status' result.json | sed 's/null//g'`
      FAILURE_REASON=`jq --raw-output '.result.failureReason' result.json | sed 's/null//g'`
      echo "Get pod info = ${STATUS}/${RESULT_STATUS}/${FAILURE_REASON}"
      sleep $(( ( RANDOM % ${SLEEP_MAX_TIME} ) + ${SLEEP_MIN_TIME} ))
    done

    # store a copy of capabilities for each model
    jq '.result.remoteCapabilities' result.json > "./modelCapabilities/${MODEL}.json"
  else
    # move on to next model
    echo "Error changing model to '${MODEL}', skipping to next model."
    sleep $(( ( RANDOM % ${SLEEP_MAX_TIME} ) + ${SLEEP_MIN_TIME} )) && rm -f result.json
    continue
  fi
done < "$input"

# EOF

