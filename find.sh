#!/bin/bash

# Filters the list of models to find those that have the following capabilities:
# - cooling mode
# - native celcius temperature
# - cooling and fan only modes
# - temperature range from 16C to 30C
# - fan levels high and low

find ./modelCapabilities/ -type f | while IFS= read -r MODEL_CAPABILITIES_FILE ; do
    echo
    echo "Getting model: ${MODEL_CAPABILITIES_FILE}"
    echo

    # check result.remoteCapabilities.modes.cool exist
    COOL=`jq --raw-output --compact-output '.modes.cool' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    if [ "${COOL}x" == "x" ] ; then
      echo "Model does not have cooling mode, skipping to next model."
      continue
    fi

    # check result.remoteCapabilities.modes.cool.temperatures.C.isNative == true
    COOL_TEMPERATURES_C_NATIVE=`jq --raw-output --compact-output '.modes.cool.temperatures.C.isNative' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    if [ "${COOL_TEMPERATURES_C_NATIVE}x" != "truex" ] ; then
      echo "Model does not have native celcius temperature, skipping to next model."
      continue
    fi

    # check result.remoteCapabilities.modes.swing does NOT exist
    #COOL_SWING=`jq --raw-output --compact-output '.modes.cool.swing' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    #if [ "${COOL_SWING}x" != "x" ] ; then
    #  echo "Model has cooling swing mode, skipping to next model."
    #  continue
    #fi

    # check result.remoteCapabilities.modes.heat exists
    #HEAT=`jq --raw-output --compact-output '.modes.heat' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    #if [ "${HEAT}x" != "x" ] ; then
    #  echo "Model has heating mode, skipping to next model."
    #  continue
    #fi
    
    # check result.remoteCapabilities.modes.cool.temperatures.C.values contains 16 to 30
    COOL_TEMPERATURES_C_VALUES=`jq --raw-output --compact-output '.modes.cool.temperatures.C.values' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    #COOL_TEMPERATURES_C_16_VALUE=`jq --raw-output '.modes.cool.temperatures.C.values | index(16)' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    #COOL_TEMPERATURES_C_30_VALUE=`jq --raw-output '.modes.cool.temperatures.C.values | index(30)' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    #if [ "${COOL_TEMPERATURES_C_16_VALUE}x" == "x" ] || [ "${COOL_TEMPERATURES_C_30_VALUE}x" == "x" ] ; then
    #  echo "Model does not have appropriate temperature range (${COOL_TEMPERATURES_C_VALUES}), skipping to next model."
    #  continue
    #fi

    if [ "${COOL_TEMPERATURES_C_VALUES}x" != "[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]x" ] ; then
      echo "Model does not have appropriate temperature range (${COOL_TEMPERATURES_C_VALUES}), skipping to next model."
      continue
    fi

    # check result.remoteCapabilities.modes.cool.fanLevels contains high and low
    COOL_FAN_LEVELS=`jq --raw-output --compact-output '.modes.cool.fanLevels' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    COOL_FAN_LEVELS_HIGH=`jq --raw-output '.modes.cool.fanLevels | index("high")' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    COOL_FAN_LEVELS_LOW=`jq --raw-output '.modes.cool.fanLevels | index("low")' "${MODEL_CAPABILITIES_FILE}" | sed 's/null//g'`
    if [ "${COOL_FAN_LEVELS_HIGH}x" == "x" ] || [ "${COOL_FAN_LEVELS_LOW}x" == "x" ] ; then
      echo "Model does not have appropriate fan levels (${COOL_FAN_LEVELS}), skipping to next model."
      continue
    fi

    if [ "${COOL_FAN_LEVELS}x" != '["high","low"]x' ] && [ "${COOL_FAN_LEVELS}x" != '["low","high"]x' ] ; then
      echo "Model does not have appropriate fan levels (${COOL_FAN_LEVELS}), skipping to next model."
      continue
    fi

    echo
    echo

    echo "POTENTIAL WINNER! = ${MODEL_CAPABILITIES_FILE}"

done

# EOF
