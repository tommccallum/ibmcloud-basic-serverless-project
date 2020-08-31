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
fi
export PATH=$PATH:${cur_folder}/ibmcloud-scripts/bin

if [ ! -e "${cur_folder}/pipeline_vars.sh" ]; then
    echo "PATH=$PATH" >> "${cur_folder}/pipeline_vars.sh"

    ## write a variable we can read that tells us if we are in the pipeline
    root_folder=$(cd $(dirname $0); pwd)
    HAS_PIPELINE_IN_CURRENT_PATH=$(echo "${root_folder}" | grep "/home/pipeline/")
    if [ -a "x$HOME" == "x/root" -a "x$HAS_PIPELINE_IN_CURRENT_PATH" != "x" ]; then
        echo " ** Pipeline detected. ** "
        echo "PIPELINE=1" >> "${cur_folder}/pipeline_vars.sh"
    else
        echo "PIPELINE=0" >> "${cur_folder}/pipeline_vars.sh"
    fi
fi

${root_folder}/make_local_env.sh
if [ $? -ne 0 ]; then
    echo "Failed to create local.env using make_local_env.sh"
    exit 1
fi

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
root_folder=$(get_root_folder)
source "${root_folder}/../project-functions.sh"
standard_start ${REDIRECT_OUTPUT}
# TODO make this per framework
check_tools

