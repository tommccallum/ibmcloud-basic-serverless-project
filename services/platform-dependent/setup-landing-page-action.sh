#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh
standard_project_script_start
root_folder=$(get_root_folder)

# SETUP logging (redirect stdout and stderr to a log file)
readonly API_NAME="public"
readonly API_PATH="/demo"
readonly API_DIR_NAME="api-public"
readonly FN_API_URL_NAME=${API_PATH}
readonly FN_NAME="demo"
readonly FN_RETURN_TYPE="html"
readonly FN_DIR_NAME="function-${FN_NAME}"
readonly FN_TEMPLATE="function-${FN_NAME}.template.js"
readonly FN_JS="function-${FN_NAME}.js"
readonly API_DIR="${root_folder}/../../${API_DIR_NAME}"
readonly PATHS_REAL_PATH="${API_DIR}/swagger-paths.json"
readonly CASES_REAL_PATH="${API_DIR}/swagger-case.json"

if [ ! -e "${API_DIR}"]; then
  _fatal "Missing directory: '$API_DIR'"
fi

_out Deploying action ${FN_PUBLIC_PACKAGE=}/${FN_NAME}

TEMPLATE_PATH="${root_folder}/../../${FN_DIR_NAME}/${FN_TEMPLATE}"
REAL_PATH="${root_folder}/../../${FN_DIR_NAME}/${FN_JS}"
if [ ! -e "$TEMPLATE_PATH" ]; then
  _fatal "Template path is invalid: ${TEMPLATE_PATH}"
fi
cp ${TEMPLATE_PATH} ${REAL_PATH}

for FWK in ${FRAMEWORKS[@]}; do
  API_URL="${FWK}_public_API_URL"
  FWK_PUBLIC_API_ENTRY=${!API_URL}
  if [ "x$FWK_PUBLIC_API_ENTRY" == "x" ]; then
    _fatal "Public API url cannot be empty for ${FWK}"
  fi
  sed -i "s#xxx-${FWK}-api-entry-xxx#${FWK_PUBLIC_API_ENTRY}#" ${REAL_PATH}
done

ibmcloud_project_login ${PROJECT_NAME}
set_default_function_namespace ${FN_NAMESPACE}

_out Creating function ${FN_NAME} in package ${FN_PUBLIC_PACKAGE}
action_name="${FN_PUBLIC_PACKAGE}/${FN_NAME}"
pre_check_for_function_action ${action_name} "${REAL_PATH}" "${NODE_VERSION}"
if [ $? -eq 0 ]; then
  ibmcloud wsk action create "${action_name}" "${REAL_PATH}" --kind ${NODE_VERSION} -a web-export true
  if [ $? -ne 0 ]; then
      _fatal "Could not create function action '${action_name}'"
  fi
fi


_out Updating ${API_NAME} API swagger templates for ${FN_NAME}
ACTION="${FN_PUBLIC_PACKAGE}/${FN_NAME}"
ACTION_NAMESPACE_AND_PACKAGE=$(ibmcloud fn action get ${ACTION} | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g")
ACTION_NAMESPACE=$(echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}')
ACTION_NAME="${FN_NAME}"
ACTION_PRODUCES_EXT="${FN_RETURN_TYPE}"
ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}.${ACTION_PRODUCES_EXT}"
ACTION_URL_NO_EXT="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}"
API_OPERATION_NAME=$(make_operation_from_name $FN_NAME)

SWAGGER_TEMPLATE_PATH="${API_DIR}/swagger-path-template.json"
if [ ! -e "${SWAGGER_TEMPLATE_PATH}" ]; then 
  _fatal "Missing swagger-path template: '${SWAGGER_TEMPLATE_PATH}'"
fi
cat ${SWAGGER_TEMPLATE_PATH} >> ${PATHS_REAL_PATH}

sed -i "s#xxx-api-operation-name-xxx#${API_OPERATION_NAME}#" ${PATHS_REAL_PATH} 
sed -i "s#xxx-api-entry-name-xxx#${FN_API_URL_NAME}#" ${PATHS_REAL_PATH} 
sed -i "s#xxx-action-name-xxx#${FN_NAME}#" ${PATHS_REAL_PATH} 
sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" ${PATHS_REAL_PATH} 
sed -i "s#xxx-action-url-xxx#${ACTION_URL}#" ${PATHS_REAL_PATH} 
sed -i "s#xxx-sample-package-xxx #${FN_PUBLIC_PACKAGE}#" ${PATHS_REAL_PATH} 

SWAGGER_TEMPLATE_PATH="${API_DIR}/swagger-case-template.json"
if [ ! -e "${SWAGGER_TEMPLATE_PATH}" ]; then 
  _fatal "Missing swagger-cases template: ${SWAGGER_TEMPLATE_PATH}"
fi
cat ${SWAGGER_TEMPLATE_PATH} >> ${CASES_REAL_PATH}

sed -i "s#xxx-api-operation-name-xxx#${API_OPERATION_NAME}#" ${CASES_REAL_PATH} 
sed -i "s#xxx-api-entry-name-xxx#${FN_API_URL_NAME}#" ${CASES_REAL_PATH} 
sed -i "s#xxx-action-name-xxx#${FN_NAME}#" ${CASES_REAL_PATH} 
sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" ${CASES_REAL_PATH} 
sed -i "s#xxx-action-url-xxx#$ACTION_URL#" ${CASES_REAL_PATH} 
sed -i "s#xxx-sample-package-xxx#${FN_PUBLIC_PACKAGE}#" ${CASES_REAL_PATH} 

# save API_URL to local.env as we will need it later on
set_var_in_env "${FN_NAME}_${API_NAME}_API_URL" "${ACTION_URL_NO_EXT}"