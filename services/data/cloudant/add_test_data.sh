#!/bin/bash

source ibm_std_functions.sh
source ../../project-functions.sh

standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

export IBM_CLOUDANT_API_KEY=$(get_service_key ${CLOUDANT_NAME})
if [ "x${IBM_CLOUDANT_API_KEY}" == "x" ]; then
    _fatal "ibm cloudant key was empty"
fi

export IBM_CLOUDANT_USERNAME=$(get_service_username ${CLOUDANT_NAME})
if [ "x${IBM_CLOUDANT_USERNAME}" == "x" ]; then
    _fatal "ibm cloudant username was empty"
fi

python add_test_data.py "${CLOUDANT_DB_NAME}"
if [ $? -ne 0 ]; then
    _fatal "Failed to create expected data in collection '${CLOUDANT_DB_NAME}'"
else
    _ok "Successfully created expected data in collection '${CLOUDANT_DB_NAME}'"
fi