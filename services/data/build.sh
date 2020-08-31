#!/bin/bash

cur_folder=$(pwd)
if [ -e "$cur_folder/pipeline_vars.sh" ]; then
    echo "Found pipeline variables file"
    source "${cur_folder}/pipeline_vars.sh"
    echo "Pipeline Flag: $PIPELINE"
    echo "PATH: $PATH"
fi

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
rm "${root_folder}/*.log"
run "${root_folder}/cloudant/build.sh"
