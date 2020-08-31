#!/bin/bash

# This adds a user, if the user already exists then it still
# returns true, but I have not found a way to test for this yet.

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start
check_basic_tools
ibmcloud_project_login ${PROJECT_NAME}
app_id_add_user ${APP_ID_NAME} ${DEMO_USER_EMAIL} ${DEMO_PASSWORD}

