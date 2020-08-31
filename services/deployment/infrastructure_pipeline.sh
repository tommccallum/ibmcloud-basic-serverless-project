#!/bin/bash

./services/deployment/startup.sh
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
./make_local_env.sh
./services/infrastructure/delete-resources.sh
if [ $? -ne 0 ]; then
    echo "Failed to remove all resources, check logs and manually remove."
    exit 1
fi
./services/infrastructure/build.sh
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
