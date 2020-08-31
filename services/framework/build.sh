#!/bin/bash

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
run "${root_folder}/setup-angular-webapp.sh"
run "${root_folder}/upload-angular-to-bucket.sh"
