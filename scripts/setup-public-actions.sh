#!/bin/bash

##############################################################################
# Copyright 2018 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##############################################################################

##############################################################################
# Updated and factored some of these scripts for our use case.
# Heavily edited by: Tom McCallum
##############################################################################


root_folder=$(cd $(dirname $0); pwd)

readonly API_NAME="public"
readonly API_DIR_NAME="api-${API_NAME}"
readonly FN_DIR_NAME="function-${API_NAME}"
readonly FN_TEMPLATE="function-${API_NAME}.template.js"
readonly FN_JS="function-${API_NAME}.js"
readonly FN_RETURN_TYPE="html"
readonly PATHS_REAL_PATH="${root_folder}/../${API_DIR_NAME}/swagger-paths.json"
readonly CASES_REAL_PATH="${root_folder}/../${API_DIR_NAME}/swagger-case.json"
  
# SETUP logging (redirect stdout and stderr to a log file)
readonly LOG_FILE="${root_folder}/deploy-${API_NAME}-function.log"
readonly ENV_FILE="${root_folder}/../local.env"

touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh

function remove_swagger_api_files() {
  if [ -e "${PATHS_REAL_PATH}" ]
  then
    rm -f ${PATHS_REAL_PATH}
  fi
  if [ -e "${CASES_REAL_PATH}" ]
  then
    rm -f ${CASES_REAL_PATH}
  fi
}

function create_actions() {
  _out Deploying actions in ${API_NAME} API

  for FWK in ${FRAMEWORKS[@]}
  do
    FN_NAME="${FWK}"
    FN_API_URL_NAME="/${FN_NAME}"

    COS_URL_HOME_BASE_VAR="${FN_NAME}_COS_URL_HOME_BASE"
    COS_URL_HOME_BASE=${!COS_URL_HOME_BASE_VAR}

    _out FN_NAME=${FN_NAME}
    _out COS_URL_HOME_BASE=${COS_URL_HOME_BASE}
    TEMPLATE_PATH="${root_folder}/../${FN_DIR_NAME}/${FN_TEMPLATE}"
    REAL_PATH="${root_folder}/../${FN_DIR_NAME}/${FN_JS}"
    cp ${TEMPLATE_PATH} ${REAL_PATH}
    
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${REAL_PATH} xxx-api-name-xxx ${FN_API_URL_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${REAL_PATH} xxx-replace-me-xxx ${COS_URL_HOME_BASE}

    _out Creating function ${FN_NAME} in package ${FN_PUBLIC_PACKAGE}
    ibmcloud wsk action create ${FN_PUBLIC_PACKAGE}/${FN_NAME} ${REAL_PATH} --kind nodejs:10 -a web-export true

    _out Updating ${API_NAME} API swagger templates    
    ACTION="${FN_PUBLIC_PACKAGE}/${FN_NAME}"
    ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get ${ACTION} | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
    ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
    ACTION_NAME="${FN_NAME}"
    ACTION_PRODUCES_EXT="${FN_RETURN_TYPE}" 
    NAMESPACE="${ACTION_NAMESPACE}"
    ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}.${ACTION_PRODUCES_EXT}"
    ACTION_URL_NO_EXT="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}"
    printf "\n${FWK}_API_URL=${ACTION_URL_NO_EXT}" >> $ENV_FILE

    OPERATION="$(tr '[:lower:]' '[:upper:]' <<< ${FN_NAME:0:1})${FN_NAME:1}"
    API_OPERATION_NAME="get${OPERATION}"

    TEMPLATE_PATH="${root_folder}/../${API_DIR_NAME}/swagger-path-template.json"
    cat ${TEMPLATE_PATH} >> ${PATHS_REAL_PATH}
    
    
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-api-operation-name-xxx ${API_OPERATION_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-api-entry-name-xxx ${FN_API_URL_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-action-name-xxx ${FN_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-namespace-xxx ${NAMESPACE}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-action-url-xxx $ACTION_URL
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${PATHS_REAL_PATH} xxx-sample-package-xxx ${FN_PUBLIC_PACKAGE}

    TEMPLATE_PATH="${root_folder}/../${API_DIR_NAME}/swagger-case-template.json"
    cat ${TEMPLATE_PATH} >> ${CASES_REAL_PATH}
    
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-api-operation-name-xxx ${API_OPERATION_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-api-entry-name-xxx ${FN_API_URL_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-action-name-xxx ${FN_NAME}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-namespace-xxx ${NAMESPACE}
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-action-url-xxx $ACTION_URL
    npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${CASES_REAL_PATH} xxx-sample-package-xxx ${FN_PUBLIC_PACKAGE}
  done
}

function set_default_function_namespace() {
  NS_EXISTS=$( ibmcloud fn namespace get ${FN_NAMESPACE} | grep "Entities in namespace" )
  if [ "x$NS_EXISTS" == "x" ]
  then
    _out Setting namespace for protected function
    ibmcloud fn namespace create ${FN_NAMESPACE} --description "Serverless Web App Sample"
  fi
  
  ibmcloud fn property set --namespace ${FN_NAMESPACE}
}

function setup() {
  remove_swagger_api_files
  set_default_function_namespace

  _out Creating package: ${FN_PUBLIC_PACKAGE}
  ibmcloud wsk package create ${FN_PUBLIC_PACKAGE}

  create_actions
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
export CLOUDANT_USERNAME CLOUDANT_PASSWORD 
export angular_COS_URL_HOME angular_COS_URL_HOME_BASE 

_out Full install output in $LOG_FILE
ibmcloud_login
setup
