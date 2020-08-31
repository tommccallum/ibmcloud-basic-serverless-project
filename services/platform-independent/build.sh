#!/bin/bash

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
rm "${root_folder}/*.log"
run "${root_folder}/app_id_add_user.sh"
run "${root_folder}/setup-function-namespace.sh"
run "${root_folder}/setup-login-actions.sh"
run "${root_folder}/setup-login-api.sh"
run "${root_folder}/setup-private-actions.sh"
run "${root_folder}/setup-private-api.sh"
