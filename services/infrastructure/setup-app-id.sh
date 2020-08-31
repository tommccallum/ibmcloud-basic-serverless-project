#!/bin/bash

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh

standard_project_script_start
check_basic_tools
ibmcloud_project_login ${PROJECT_NAME}
create_app_id_instance ${APP_ID_NAME}
if [ $? -eq 0 ]
then
    create_alias_for_instance ${APP_ID_NAME}
    create_app_id_credentials ${APP_ID_NAME}
fi

