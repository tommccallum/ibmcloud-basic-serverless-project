#!/bin/bash


echo "OS Details:"
cat /etc/os-release
echo "Kernel:"
uname -a
echo "Your current directory is: $(pwd)"
echo "Using IBM cli version: $(ibmcloud --version)"
echo "Cloning ibmcloud-scripts"
git clone https://github.com/tommccallum/ibmcloud-scripts
echo "Adding ibmcloud-scripts to path"
export PATH=$PATH:$(pwd)/ibmcloud-scripts

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
root_folder=$(get_root_folder)
echo "ROOT_FOLDER: ${root_folder}"
source "${root_folder}/../project-functions.sh"
standard_start ${REDIRECT_OUTPUT}
check_project_tools