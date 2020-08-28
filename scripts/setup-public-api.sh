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



function create_public_api_endpoints() {
  _out Deploying API: ${API_NAME}

  # for the last one we need to remove final ',' character
  # because sed is greedy in its matching we can do a simple replacement
  ${root_folder}/remove_last_comma.py ${CASES_REAL_PATH} 
  ${root_folder}/remove_last_comma.py ${PATHS_REAL_PATH} 

  cp ${root_folder}/../${API_DIR_NAME}/swagger-template.json ${root_folder}/../${API_DIR_NAME}/swagger.json
  SWAGGER_CONF="${root_folder}/../${API_DIR_NAME}/swagger.json"
  sed -i "s/xxx-api-name-xxx/${API_NAME}/" ${SWAGGER_CONF}
  sed -i "s/xxx-api-basepath-xxx/${API_BASEPATH}/" ${SWAGGER_CONF}
  sed -i -e "/xxx-paths-xxx/ { r ${PATHS_REAL_PATH}" -e "d;}" ${SWAGGER_CONF}
  sed -i -e "/xxx-operations-xxx/ { r ${CASES_REAL_PATH}" -e "d;}" ${SWAGGER_CONF}

  ibmcloud wsk api create --config-file ${root_folder}/../${API_DIR_NAME}/swagger.json 
}

function update_redirect() {
  angular_PUBLIC_API_ENTRY=$(ibmcloud wsk api list | grep angular | awk '{print $4}')

  _out Updating function: ${FN_GENERIC_PACKAGE}/redirect
  _out PUBLIC_API_ENTRY=${angular_PUBLIC_API_ENTRY}
  CONFIG_FILE="${root_folder}/../function-login/config.json"
  rm $CONFIG_FILE
  touch $CONFIG_FILE
  printf "{\n" >> $CONFIG_FILE
  printf "\"client_id\": \"" >> $CONFIG_FILE
  printf $APPID_CLIENTID >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"client_secret\": \"" >> $CONFIG_FILE
  printf $APPID_SECRET >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"oauth_url\": \"" >> $CONFIG_FILE
  printf $APPID_OAUTHURL >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"webapp_redirect\": \"" >> $CONFIG_FILE
  printf $angular_PUBLIC_API_ENTRY >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"redirect_uri\": \"" >> $CONFIG_FILE
  printf $API_LOGIN >> $CONFIG_FILE
  printf "\"\n" >> $CONFIG_FILE
  printf "}" >> $CONFIG_FILE
  CONFIG=`cat $CONFIG_FILE`
  
  ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/redirect ${root_folder}/../function-login/redirect.js --kind nodejs:10 -a web-export true -p config "${CONFIG}"
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
  set_default_function_namespace

  _out Creating api: ${API_NAME}
  create_public_api_endpoints
  update_redirect
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

_out Full install output in $LOG_FILE
ibmcloud_login
setup
