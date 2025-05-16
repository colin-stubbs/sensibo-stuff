#!/bin/bash

# Generates a list of models that are not present in the modelCapabilities directory but which existin in the models.json file.

# migrate to pulling this live?
jq '.result.brands[][]' --raw-output models.json > models.txt
input="models.txt"
output="missing.txt"

echo -n > ${output}

while IFS= read -r MODEL
do
  test -f "./modelCapabilities/${MODEL}.json" || echo "${MODEL}" >> ${output}
done < "$input"

# EOF

