#!/bin/bash

# Called every time a project is run

source ibm_std_functions.sh
source ../project-functions.sh

standard_project_script_start ${LOCAL_ENV_FILENAME}
sanity_check_local_vars
root_folder=$(get_root_folder)

function check_old_version() {
    local old_version="${VERSION}"
    local old_api_key="${PROJECT_PREFIX}-${old_version}"
    _out "Checking for old version api key: ${old_api_key}"
    check_if_api_key_exists "${old_api_key}"
    if [ $? -eq 0 ]; then
        _err "Old version exists (${old_api_key}), you cannot rebuild the infrastructure until this is removed."
        ibmcloud iam api-keys | grep "^${old_api_key}" | tee -a $LOG_FILE | tee /dev/tty
        _fatal "See '$(abbreviate_file_path ${LOG_FILE})' for more details."
    fi
}

check_old_version
old_version=$VERSION
bump_version "${root_folder}/../../${LOCAL_ENV_TEMPLATE}"
cp "${root_folder}/../../${LOCAL_ENV_TEMPLATE}" "${root_folder}/../../${LOCAL_ENV_FILENAME}"
ENV_FILE=$(find_environment)
exit_on_error $?
source ${ENV_FILE}
sanity_check_local_vars
if [ $VERSION -eq $old_version ]
then
    _fatal "Bump failed, nothing has been modified."
fi
_ok "Building ${PROJECT_PREFIX} Version ${VERSION}"
