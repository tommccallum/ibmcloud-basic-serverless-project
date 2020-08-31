#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh

standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

create_object_storage_instance ${OBJECT_STORAGE_NAME}
if [ $? -eq 0 ]
then
  create_object_storage_credentials ${OBJECT_STORAGE_NAME}
fi

