#!/bin/bash

# Load a url in the browser
source ibm_std_functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}
call_api "demo"
