#!/bin/bash

root_folder=$(cd $(dirname $0); pwd)
${root_folder}/startup.sh
if [ $? -ne 0 ]; then
    echo "Startup unexpectedly failed.  Check log, take copy of logs and screenshots, and report."
    exit 1
fi
# Even though startup.sh exports the variable PATH updated,
# as this is a PARENT process we do not see this change.
# Therefore we have to add it ourselves for later processes.
cur_folder="$(pwd)"
if [ -e "${cur_folder}/ibmcloud-scripts/bin" ]
then
    echo "Adding ibmcloud-scripts to path"
    export PATH=$PATH:${cur_folder}/ibmcloud-scripts/bin
else
    echo "Failed to find ibmcloud-scripts, unable to continue"
    exit 1
fi
shorten_file_path.py "/home/pipeline/ibmcloud-scripts/bin/deploy-ibm_login.log" "/home/pipeline/services"

${root_folder}/make_local_env.sh
if [ $? -ne 0 ]; then
    echo "Failed to create local.env using make_local_env.sh"
    exit 1
fi
${root_folder}/../infrastructure/delete-resources.sh
if [ $? -ne 0 ]; then
    echo "Failed to remove all resources, check logs and manually remove."
    exit 1
fi
${root_folder}/../infrastructure/build.sh
if [ $? == 0 ]; then
    echo
    echo
    echo "******************************************************"
    echo "You will need to rebuild the other service layers now."
    echo "******************************************************"
else
    echo "Oops, something went wrong. Check the log and try building locally."
    exit 1
fi
