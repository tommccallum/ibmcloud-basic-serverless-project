#!/bin/bash

root_folder=$(
  cd $(dirname $0)
  pwd
)

# SETUP logging (redirect stdout and stderr to a log file)
readonly FN_NAME="demo"
readonly FN_RETURN_TYPE="html"
readonly LOG_FILE="${root_folder}/deploy-${FN_NAME}-function.log"
readonly ENV_FILE="${root_folder}/../local.env"
readonly API_PATH="/demo"
readonly FN_API_URL_NAME=${API_PATH}
readonly API_DIR_NAME="api-public"
readonly FN_DIR_NAME="function-${FN_NAME}"
readonly FN_TEMPLATE="function-${FN_NAME}.template.js"
readonly FN_JS="function-${FN_NAME}.js"
readonly PATHS_REAL_PATH="${root_folder}/../${API_DIR_NAME}/swagger-paths.json"
readonly CASES_REAL_PATH="${root_folder}/../${API_DIR_NAME}/swagger-case.json"

touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh

function create_demo_action() {
  _out Deploying action ${FN_PUBLIC_PACKAGE=}/${FN_NAME}

  TEMPLATE_PATH="${root_folder}/../${FN_DIR_NAME}/${FN_TEMPLATE}"
  REAL_PATH="${root_folder}/../${FN_DIR_NAME}/${FN_JS}"
  cp ${TEMPLATE_PATH} ${REAL_PATH}

  for FWK in ${FRAMEWORKS[@]}; do
    API_URL=${FWK}_API_URL
    FWK_PUBLIC_API_ENTRY=${!API_URL}
    _out FWK_PUBLIC_API_ENTRY=${FWK_PUBLIC_API_ENTRY}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${REAL_PATH} xxx-${FWK}-api-entry-xxx ${FWK_PUBLIC_API_ENTRY}
  done

  ibmcloud wsk action create ${FN_PUBLIC_PACKAGE}/${FN_NAME} ${REAL_PATH} --kind nodejs:10 -a web-export true
}

function add_action_to_api_swagger() {
  _out Updating ${API_NAME} API swagger templates for ${FN_NAME}

  ACTION="${FN_PUBLIC_PACKAGE}/${FN_NAME}"
  ACTION_NAMESPACE_AND_PACKAGE=$(ibmcloud fn action get ${ACTION} | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g")
  ACTION_NAMESPACE=$(echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}')
  ACTION_NAME="${FN_NAME}"
  ACTION_PRODUCES_EXT="${FN_RETURN_TYPE}"
  NAMESPACE="${ACTION_NAMESPACE}"
  ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}.${ACTION_PRODUCES_EXT}"
  ACTION_URL_NO_EXT="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}"
  printf "\n${FN_NAME}_API_URL=${ACTION_URL_NO_EXT}" >> $ENV_FILE

  OPERATION="$(tr '[:lower:]' '[:upper:]' <<< ${FN_NAME:0:1})${FN_NAME:1}"
  API_OPERATION_NAME="get${OPERATION}"

  TEMPLATE_PATH="${root_folder}/../${API_DIR_NAME}/swagger-path-template.json"
  cat ${TEMPLATE_PATH} >>${PATHS_REAL_PATH}

  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-api-operation-name-xxx ${API_OPERATION_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-api-action-name-xxx ${FN_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-api-entry-name-xxx ${FN_API_URL_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-action-name-xxx ${FN_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-namespace-xxx ${NAMESPACE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-action-url-xxx $ACTION_URL
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-sample-package-xxx ${FN_PUBLIC_PACKAGE}

  TEMPLATE_PATH="${root_folder}/../${API_DIR_NAME}/swagger-case-template.json"
  cat ${TEMPLATE_PATH} >>${CASES_REAL_PATH}

  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-api-operation-name-xxx ${API_OPERATION_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-api-entry-name-xxx ${FN_API_URL_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-action-name-xxx ${FN_NAME}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-namespace-xxx ${NAMESPACE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-action-url-xxx $ACTION_URL
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-sample-package-xxx ${FN_PUBLIC_PACKAGE}
}

function set_default_function_namespace() {
  NS_EXISTS=$(ibmcloud fn namespace get ${FN_NAMESPACE} | grep "Entities in namespace")
  if [ "x$NS_EXISTS" == "x" ]; then
    _out Setting namespace for functions
    ibmcloud fn namespace create ${FN_NAMESPACE} --description "Serverless Web App Sample"
  fi

  ibmcloud fn property set --namespace ${FN_NAMESPACE}
}

function setup() {
  set_default_function_namespace
  create_demo_action
  add_action_to_api_swagger
}

# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export IBMCLOUD_API_KEY BLUEMIX_REGION APPID_TENANTID APPID_OAUTHURL APPID_CLIENTID APPID_SECRET
export CLOUDANT_USERNAME CLOUDANT_PASSWORD API_HOME
export angular_COS_URL_HOME angular_COS_URL_HOME_BASE

_out Full install output in $LOG_FILE
ibmcloud_login
setup
