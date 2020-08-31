#!/bin/bash

echo "OS Details:"
cat /etc/os-release
echo "Kernel:"
uname -a
echo "Your current directory is: $(pwd)"
echo "Using IBM cli version: $(ibmcloud --version)"
echo "Home directory is: ${HOME}"
echo "Cloning ibmcloud-scripts"
cur_folder="$(pwd)"
git clone https://github.com/tommccallum/ibmcloud-scripts ${cur_folder}/ibmcloud-scripts
echo "Adding ibmcloud-scripts to path"
export PATH=$PATH:${cur_folder}/ibmcloud-scripts
REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
root_folder=$(get_root_folder)
echo "ROOT_FOLDER: ${root_folder}"
source "${root_folder}/../project-functions.sh"
standard_start ${REDIRECT_OUTPUT}
# TODO make this per framework
check_tools