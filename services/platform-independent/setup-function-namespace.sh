#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

create_function_namespace ${FN_NAMESPACE} ${FN_NS_DESCRIPTION}
if [ $? -ne 0 ]; then
    _fatal "Failed to create namespace: ${FN_NAMESPACE}"
fi