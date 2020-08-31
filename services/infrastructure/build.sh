#!/bin/bash

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
rm "${root_folder}/*.log"
run "${root_folder}/setup-project-first.sh"
run "${root_folder}/setup-project-next.sh"
run "${root_folder}/setup-project-keys.sh"
run "${root_folder}/setup-add-id.sh"
run "${root_folder}/setup-cloudant.sh"
run "${root_folder}/setup-object-storage.sh"
run "${root_folder}/setup-buckets.sh"
