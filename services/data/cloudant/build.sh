#!/bin/bash

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
standard_start ${REDIRECT_OUTPUT}

root_folder=$(get_root_folder)
rm "${root_folder}/*.log"
run "${root_folder}/install.sh"
run "${root_folder}/create_collection.sh"
run "${root_folder}/add_test_data.sh"
