#!/bin/bash

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start

root_folder=$(get_root_folder)
if [ "x$OBJECT_STORAGE_URL" == "x" ]; then
  _fatal "Missing object storge url from environment"
fi

FRAMEWORK="angularwebapp"
FRAMEWORK_DIR="${root_folder}/../../${FRAMEWORKS_ROOT_DIR}/${FRAMEWORK}"
if [ ! -e "${FRAMEWORK_DIR}" ]; then
  _fatal "Missing directory: ${FRAMEWORK_DIR}"
fi

_out Building Angular application
cd ${FRAMEWORK_DIR}
ng build

ibmcloud_project_login ${PROJECT_NAME}

_out Locating bucket

COS_ID=$(ibmcloud resource service-instance ${OBJECT_STORAGE_NAME} --id | awk '/crn/{ print $2 }')
if [ "x$COS_ID" == "x" ]; then
  _fatal "Unable to get storage-object instance id"
fi
BUCKET_NAME=$(ibmcloud cos buckets --ibm-service-instance-id="${COS_ID}" | grep "${FRAMEWORK}" | awk '{print $1}')
if [ "x$BUCKET_NAME" == "x" ]; then
  _fatal "Unable to get storage-object bucket name for ${FRAMEWORK}"
fi
_out BUCKET_NAME: ${BUCKET_NAME}

BUCKET_URL="https://s3.${BLUEMIX_REGION}.${OBJECT_STORAGE_URL}/${BUCKET_NAME}"
_out BUCKET_URL: $BUCKET_URL

# this is the second time we try to set this variable which is used in platform-dependent setup code.
# the first time is in setup-buckets.sh.
# we do it here as well just in case we missed it for some reason.
COS_URL_HOME_BASE_VAR="${FRAMEWORK}_COS_URL_HOME_BASE}"
COS_URL_HOME_BASE="${!COS_URL_HOME_BASE_VAR}"
if [ "x${COS_URL_HOME_BASE}" == "x" ]; then
  set_var_in_env "${FRAMEWORK}_COS_URL_HOME_BASE" "${BUCKET_URL}"
fi

_out Modify urls in distribution
sed -i "s#src=\"#src=\"${BUCKET_URL}#" ${FRAMEWORK_DIR}/dist/index.html 

upload_directory_to_storage_bucket ${BUCKET_URL} "${FRAMEWORK_DIR}/dist"


