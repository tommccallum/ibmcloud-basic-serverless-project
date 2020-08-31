#!/bin/bash

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
run "${root_folder}/setup-public-actions.sh"
run "${root_folder}/setup-landing-page-action.sh"
run "${root_folder}/setup-public-api.sh"
run "${root_folder}/update-api-redirects.sh"
