#!/bin/bash

echo "[$(date)] [$(basename $0)] Startup"
echo "OS Details:"
cat /etc/os-release
echo "Kernel:"
uname -a
echo "[$(date)] [$(basename $0)] Your current directory is: $(pwd)"
echo "[$(date)] [$(basename $0)] Using IBM cli version: $(ibmcloud --version)"
echo "[$(date)] [$(basename $0)] Home directory is: ${HOME}"
cur_folder="$(pwd)"
if [ ! -e "${cur_folder}/ibmcloud-scripts" ]; then
    # this is only done in the first build stage
    echo "[$(date)] [$(basename $0)] Cloning ibmcloud-scripts"
    time git clone https://github.com/tommccallum/ibmcloud-scripts ${cur_folder}/ibmcloud-scripts
    ${cur_folder}/ibmcloud-scripts/install.sh
fi
export PATH=$PATH:${cur_folder}/ibmcloud-scripts/bin

if [ ! -e "${cur_folder}/pipeline_vars.sh" ]; then
    echo "export PATH=$PATH" >> "${cur_folder}/pipeline_vars.sh"

    ## write a variable we can read that tells us if we are in the pipeline
    root_folder=$(cd $(dirname $0); pwd)
    HAS_PIPELINE_IN_CURRENT_PATH=$(echo "${root_folder}" | grep "/home/pipeline/")
    if [ "x$HOME" == "x/root" -a "x$HAS_PIPELINE_IN_CURRENT_PATH" != "x" ]; then
        echo "[$(date)] [$(basename $0)] Setting PIPELINE flag to 1"
        echo "export PIPELINE=1" >> "${cur_folder}/pipeline_vars.sh"
    else
        echo "[$(date)] [$(basename $0)] Setting PIPELINE flag to 0"
        echo "export PIPELINE=0" >> "${cur_folder}/pipeline_vars.sh"
    fi
else
    echo "[$(date)] [$(basename $0)] Loading existing pipeline variables"
    source "${cur_folder}/pipeline_vars.sh"
    echo "[$(date)] [$(basename $0)] Pipeline Flag: $PIPELINE"
    echo "[$(date)] [$(basename $0)] PATH: $PATH"
fi

${cur_folder}/services/deployment/make_local_env.sh
if [ $? -ne 0 ]; then
    echo "[$(date)] [$(basename $0)] Failed to create local.env using make_local_env.sh"
    exit 1
fi

REDIRECT_OUTPUT="FALSE"
source ibm_std_functions.sh
root_folder=$(get_root_folder)
source "${root_folder}/../project-functions.sh"
standard_start ${REDIRECT_OUTPUT}
# TODO make this per framework
check_tools

