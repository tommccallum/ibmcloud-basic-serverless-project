#!/bin/bash

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

create_function_namespace ${FN_NAMESPACE} ${FN_NS_DESCRIPTION}
if [ $? -ne 0 ]; then
    _fatal "Failed to create namespace: ${FN_NAMESPACE}"
fi