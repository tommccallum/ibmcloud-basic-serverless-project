#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh

if [ ! -e "../../${LOCAL_ENV_FILENAME}" ]; then
    _out "This is the first run."
    if [ -e "../../${LOCAL_ENV_TEMPLATE}" ]; then
        _out "Copying template over to active ${LOCAL_ENV_FILENAME}"
        cp ../../${LOCAL_ENV_TEMPLATE} ../../${LOCAL_ENV_FILENAME}
    else
        _fatal "Could not find template: ${LOCAL_ENV_TEMPLATE}"
    fi
    source ../../${LOCAL_ENV_FILENAME}
    sanity_check_local_vars
fi
