#!/bin/bash

cur_folder=$(pwd)
if [ -e "$cur_folder/pipeline_vars.sh" ]; then
    echo "[$(date)] [$(basename $0)] Found pipeline variables file"
    source "${cur_folder}/pipeline_vars.sh"
    echo "[$(date)] [$(basename $0)] Pipeline Flag: $PIPELINE"
    echo "[$(date)] [$(basename $0)] PATH: $PATH"
fi

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
rm "${root_folder}/*.log"
run "${root_folder}/setup-public-actions.sh"
run "${root_folder}/setup-landing-page-action.sh"
run "${root_folder}/setup-public-api.sh"
run "${root_folder}/update-api-redirects.sh"
