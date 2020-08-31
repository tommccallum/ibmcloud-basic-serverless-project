#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh

standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

create_cloudant_service ${CLOUDANT_NAME}
if [ $? -eq 0 ]
then
  create_cloudant_credentials ${CLOUDANT_NAME}
fi
