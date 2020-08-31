#!/bin/bash


source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh

standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

if [ "x$OBJECT_STORAGE_URL" == "x" ]; then
  _fatal "Missing object storge url from environment"
fi

APPID_TENANTID=$(app_id_get_tenant_id ${APP_ID_NAME})
exit_on_error $? 
for fw in ${FRAMEWORKS[@]}
do
  BUCKET_NAME="${BUCKET_PREFIX}-${APPID_TENANTID}-${fw}"
  create_bucket ${BUCKET_NAME} ${OBJECT_STORAGE_NAME}

  BUCKET_URL="https://s3.${BLUEMIX_REGION}.${OBJECT_STORAGE_URL}/${BUCKET_NAME}"
  _out BUCKET_URL: $BUCKET_URL
  set_var_in_env "${fw}_COS_URL_HOME_BASE" "${BUCKET_URL}"
done
 
  
  

  


