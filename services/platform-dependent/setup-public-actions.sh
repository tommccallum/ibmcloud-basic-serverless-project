#!/bin/bash

function create_framework_entry_points() {
  _out Deploying framework entry points in ${API_NAME} API

  
  for FWK in ${FRAMEWORKS[@]}
  do
    FN_NAME="${FWK}"
    FN_API_URL_NAME="/${FN_NAME}"
    _out Creating action for ${FN_NAME}

    # objectstorage url + bucket name comes from framework/upload-*-to-bucket.sh
    COS_URL_HOME_BASE_VAR="${FN_NAME}_COS_URL_HOME_BASE"
    COS_URL_HOME_BASE=${!COS_URL_HOME_BASE_VAR}
    if [ "x$COS_URL_HOME_BASE" == "x" ]; then
      _fatal "Could not find Cloud Object Storage URL for ${FN_NAME}, have you run the framework build yet?"
    fi
    _out Cloud Object Storage URL: ${COS_URL_HOME_BASE}

    # this template is the html that loads the bundles
    # most likely needs to be per framework
    TEMPLATE_PATH="${root_folder}/../../${FN_DIR_NAME}/${FN_TEMPLATE}"
    REAL_PATH="${root_folder}/../../${FN_DIR_NAME}/${FN_JS}"
    if [ ! -e "$TEMPLATE_PATH" ]; then
      _fatal "Failed to find template for ${API_NAME} function template"
    fi
    cp ${TEMPLATE_PATH} ${REAL_PATH}
  
    sed -i "s#xxx-api-name-xxx#${FN_API_URL_NAME}#" ${REAL_PATH} 
    sed -i "s#xxx-replace-me-xxx#${COS_URL_HOME_BASE}#" ${REAL_PATH} 

    _out Creating function ${FN_NAME} in package ${FN_PUBLIC_PACKAGE}
    action_name="${FN_PUBLIC_PACKAGE}/${FN_NAME}"
    pre_check_for_function_action ${action_name} "${REAL_PATH}" "${NODE_VERSION}"
    if [ $? -eq 0 ]; then
      ibmcloud wsk action create "${action_name}" "${REAL_PATH}" --kind ${NODE_VERSION} -a web-export true
      if [ $? -ne 0 ]; then
          _fatal "Could not create function action '${action_name}'"
      fi
    fi
    
    _out Updating ${API_NAME} API swagger templates
    _out Entry point will be ${FN_API_URL_NAME}
    local ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get ${action_name} | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
    local ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
    local ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${FN_NAME}.${FN_RETURN_TYPE}"
    local ACTION_URL_NO_EXT="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${FN_NAME}"
    local API_OPERATION_NAME=$(make_operation_from_name $FN_NAME)

    local SWAGGER_TEMPLATE_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-path-template.json"
    if [ ! -e "${SWAGGER_TEMPLATE_PATH}" ]; then 
      _fatal "Missing template: ${SWAGGER_TEMPLATE_PATH}"
    fi
    cat ${SWAGGER_TEMPLATE_PATH} >> ${PATHS_REAL_PATH}
    
    sed -i "s#xxx-api-operation-name-xxx#${API_OPERATION_NAME}#" ${PATHS_REAL_PATH} 
    sed -i "s#xxx-api-entry-name-xxx#${FN_API_URL_NAME}#" ${PATHS_REAL_PATH} 
    sed -i "s#xxx-action-name-xxx#${FN_NAME}#" ${PATHS_REAL_PATH} 
    sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" ${PATHS_REAL_PATH} 
    sed -i "s#xxx-action-url-xxx#${ACTION_URL}#" ${PATHS_REAL_PATH} 
    sed -i "s#xxx-sample-package-xxx #${FN_PUBLIC_PACKAGE}#" ${PATHS_REAL_PATH} 

    SWAGGER_TEMPLATE_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-case-template.json"
    if [ ! -e "${SWAGGER_TEMPLATE_PATH}" ]; then 
      _fatal "Missing template: ${SWAGGER_TEMPLATE_PATH}"
    fi
    cat ${SWAGGER_TEMPLATE_PATH} >> ${CASES_REAL_PATH}
    
    sed -i "s#xxx-api-operation-name-xxx#${API_OPERATION_NAME}#" ${CASES_REAL_PATH} 
    sed -i "s#xxx-api-entry-name-xxx#${FN_API_URL_NAME}#" ${CASES_REAL_PATH} 
    sed -i "s#xxx-action-name-xxx#${FN_NAME}#" ${CASES_REAL_PATH} 
    sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" ${CASES_REAL_PATH} 
    sed -i "s#xxx-action-url-xxx#$ACTION_URL#" ${CASES_REAL_PATH} 
    sed -i "s#xxx-sample-package-xxx#${FN_PUBLIC_PACKAGE}#" ${CASES_REAL_PATH} 

    # save API_URL to local.env as we will need it later on
    set_var_in_env "${FWK}_${API_NAME}_API_URL" "${ACTION_URL_NO_EXT}"
  done
}

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start
root_folder=$(get_root_folder)
ibmcloud_project_login ${PROJECT_NAME}

readonly API_NAME="public"
readonly API_DIR_NAME="api-${API_NAME}"
readonly FN_DIR_NAME="function-${API_NAME}"
readonly FN_TEMPLATE="function-${API_NAME}.template.js"
readonly FN_JS="function-${API_NAME}.js"
readonly FN_RETURN_TYPE="html"
readonly PATHS_REAL_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-paths.json"
readonly CASES_REAL_PATH="${root_folder}/../../${API_DIR_NAME}/swagger-case.json"

[[ -e "${PATHS_REAL_PATH}" ]] && rm ${PATHS_REAL_PATH}
[[ -e "${CASES_REAL_PATH}" ]] && rm ${CASES_REAL_PATH}
set_default_function_namespace ${FN_NAMESPACE}
create_function_package ${FN_PUBLIC_PACKAGE}
create_framework_entry_points
