#!/bin/bash


echo "OS Details:"
cat /etc/os-release
echo "Kernel:"
uname -a
echo "Your current directory is: $(pwd)"
echo "Using IBM cli version: $(ibmcloud --version)"
echo "Home directory is: ${HOME}"
cur_folder="$(pwd)"
if [ ! -e "${cur_folder}/ibmcloud-scripts" ]; then
    # this is only done in the first build stage
    echo "Cloning ibmcloud-scripts"
    git clone https://github.com/tommccallum/ibmcloud-scripts ${cur_folder}/ibmcloud-scripts
    ${cur_folder}/ibmcloud-scripts/install.sh
else 
    # we want to update our build stage
    echo "Pulling latest sources"
    git pull
fi
export PATH=$PATH:${cur_folder}/ibmcloud-scripts/bin

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
root_folder=$(get_root_folder)
source "${root_folder}/../project-functions.sh"
standard_start ${REDIRECT_OUTPUT}
# TODO make this per framework
check_tools