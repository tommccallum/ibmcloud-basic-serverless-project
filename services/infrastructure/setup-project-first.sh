#!/bin/bash

# do not use _out and similar commands from ibm_std_functions.sh in this file
# TODO this has been made redundant by make_local_env.sh, do we still need it?
source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
if [ "x$LOCAL_ENV_FILENAME" == "x" ]; then
    echo "Failed to find expected local environment file, report error."
    exit 1
fi
if [ ! -e "$root_folder/../../${LOCAL_ENV_FILENAME}" ]; then
    echo "This is the first run."
    if [ -e "$root_folder/../../${LOCAL_ENV_TEMPLATE}" ]; then
        echo "Copying template over to active ${LOCAL_ENV_FILENAME}"
        cp $root_folder/../../${LOCAL_ENV_TEMPLATE} $root_folder/../../${LOCAL_ENV_FILENAME}
    else
        echo "Could not find template: ${LOCAL_ENV_TEMPLATE}"
    fi
    source $root_folder/../../${LOCAL_ENV_FILENAME}
    sanity_check_local_vars
fi
