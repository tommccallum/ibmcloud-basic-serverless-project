#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}
root_folder=$(get_root_folder)

readonly API_NAME="private"
readonly API_DIR_NAME="api-${API_NAME}"
readonly FN_DIR_NAME="function-${API_NAME}"
readonly FN_TEMPLATE="function-${API_NAME}.template.js"
readonly FN_JS="function-${API_NAME}.js"
readonly FN_RETURN_TYPE="json"
readonly PATHS_REAL_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-paths.json"
readonly CASES_REAL_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-case.json"

[[ -e "${PATHS_REAL_PATH}" ]] && rm ${PATHS_REAL_PATH}
[[ -e "${CASES_REAL_PATH}" ]] && rm ${CASES_REAL_PATH}

set_default_function_namespace ${FN_NAMESPACE}
if [ $? -ne 0 ]; then
    _err "Failed to set default namespace ${FN_NAMESPACE}"
    ibmcloud fn namespace list
    _fatal
fi
create_function_package ${FN_PRIVATE_PACKAGE}


_out "Writing out cloudant service key to config"
readonly CONFIG_FILE="${root_folder}/../../function-private/config.json"
[[ -e "$CONFIG_FILE" ]]  && rm $CONFIG_FILE
touch $CONFIG_FILE
CLOUDANT_KEY=$(get_service_key "${CLOUDANT_NAME}")
if [ "x${CLOUDANT_KEY}" == "x" ]; then
  _fatal "Cloudant key is empty, have you setup this service up yet?"
fi
CLOUDANT_USERNAME=$(get_service_username ${CLOUDANT_NAME})
if [ "x${CLOUDANT_USERNAME}" == "x" ]; then
    _fatal "ibm cloudant username was empty"
fi
printf "{\n" >> $CONFIG_FILE
printf "\"cloudant_username\": \"" >> $CONFIG_FILE
printf $CLOUDANT_USERNAME >> $CONFIG_FILE
printf "\",\n" >> $CONFIG_FILE
printf "\"cloudant_key\": \"" >> $CONFIG_FILE
printf $CLOUDANT_KEY >> $CONFIG_FILE
printf "\"\n" >> $CONFIG_FILE
printf "}" >> $CONFIG_FILE
CONFIG=$( cat $CONFIG_FILE )

private_actions=( $(find ${root_folder}/../../function-private -type f -iname "*.js" | grep -v "/dist/" ) )
_out Found ${#private_actions[@]} private actions

for action_js in ${private_actions[@]}
do
  _out "Found script $(abbreviate_file_path ${action_js})"
  FN_NAME=$(basename $action_js | sed "s/\.js//")
  if [ "x$FN_NAME" == "x" ]; then
    _fatal "Could not form action name from path '${action_js}'"
  fi
  FN_API_URL_NAME="/${FN_NAME}"
    
  _out Creating function ${FN_NAME} in package ${FN_PRIVATE_PACKAGE}
  action_name="${FN_PRIVATE_PACKAGE}/${FN_NAME}"
  pre_check_for_function_action ${action_name} "${action_js}" "${NODE_VERSION}"
  if [ $? -eq 0 ]; then
    ibmcloud wsk action create "${action_name}" "${action_js}" --kind ${NODE_VERSION} -a web-export true -p config "${CONFIG}"
    if [ $? -ne 0 ]; then
      _fatal "Could not create function action '${action_name}'"
    else 
      _ok "Created '${action_name}' successfully"
    fi
  fi

  _out Updating ${API_NAME} API swagger templates
  _out Entry point will be ${FN_API_URL_NAME}
  ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get "${action_name}" | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
  if [ "x${ACTION_NAMESPACE_AND_PACKAGE}" == "x" ]; then
    _fatal "${action_name} is missing, did it get created properly?"
  fi
  ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
  ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${FN_NAME}.${FN_RETURN_TYPE}"
  ACTION_URL_NO_EXT="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${FN_NAME}"
  API_OPERATION_NAME=$(make_operation_from_name $FN_NAME)

  SWAGGER_TEMPLATE_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-path-template.json"
  if [ ! -e "${SWAGGER_TEMPLATE_PATH}" ]; then
    _fatal "Could not find template '$(abbreviate_file_path ${SWAGGER_TEMPLATE_PATH})'"
  fi
  cat ${SWAGGER_TEMPLATE_PATH} >> ${PATHS_REAL_PATH}
  
  sed -i "s#xxx-api-operation-name-xxx#${API_OPERATION_NAME}#" ${PATHS_REAL_PATH} 
  sed -i "s#xxx-api-entry-name-xxx#${FN_API_URL_NAME}#" ${PATHS_REAL_PATH} 
  sed -i "s#xxx-action-name-xxx#${FN_NAME}#" ${PATHS_REAL_PATH} 
  sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" ${PATHS_REAL_PATH} 
  sed -i "s#xxx-action-url-xxx#${ACTION_URL}#" ${PATHS_REAL_PATH} 
  sed -i "s#xxx-sample-package-xxx#${FN_PRIVATE_PACKAGE}#" ${PATHS_REAL_PATH} 

  SWAGGER_TEMPLATE_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-case-template.json"
  if [ ! -e "${SWAGGER_TEMPLATE_PATH}" ]; then
    _fatal "Could not find template '$(abbreviate_file_path ${SWAGGER_TEMPLATE_PATH})'"
  fi
  cat ${SWAGGER_TEMPLATE_PATH} >> ${CASES_REAL_PATH}
  
  sed -i "s#xxx-api-operation-name-xxx#${API_OPERATION_NAME}#" ${CASES_REAL_PATH} 
  sed -i "s#xxx-api-entry-name-xxx#${FN_API_URL_NAME}#" ${CASES_REAL_PATH} 
  sed -i "s#xxx-action-name-xxx#${FN_NAME}#" ${CASES_REAL_PATH} 
  sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" ${CASES_REAL_PATH} 
  sed -i "s#xxx-action-url-xxx#$ACTION_URL#" ${CASES_REAL_PATH} 
  sed -i "s#xxx-sample-package-xxx#${FN_PRIVATE_PACKAGE}#" ${CASES_REAL_PATH} 

  # save API_URL to local.env as we will need it later on
  set_var_in_env "${FN_NAME}_${API_NAME}_API_URL" "${ACTION_URL_NO_EXT}"
done