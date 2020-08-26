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

# SETUP logging (redirect stdout and stderr to a log file)
readonly LOG_FILE="${root_folder}/deploy-protected-function.log"
readonly ENV_FILE="${root_folder}/../local.env"

touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh

function setup() {
  NS_EXISTS=$( ibmcloud fn namespace get ${FN_NAMESPACE} | grep "Entities in namespace" )
  if [ "x$NS_EXISTS" == "x" ]
  then
    _out Setting namespace for protected function
    ibmcloud fn namespace create ${FN_NAMESPACE} --description "Serverless Web App Sample"
  fi
  
  ibmcloud fn property set --namespace ${FN_NAMESPACE}
  
  _out Preparing deployment of the protected function
  ibmcloud wsk package create ${FN_SAMPLE_PACKAGE}

  readonly CONFIG_FILE="${root_folder}/../function-protected/config.json"
  rm $CONFIG_FILE
  touch $CONFIG_FILE

  printf "{\n" >> $CONFIG_FILE
  printf "\"cloudant_username\": \"" >> $CONFIG_FILE
  printf $CLOUDANT_USERNAME >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"cloudant_password\": \"" >> $CONFIG_FILE
  printf $CLOUDANT_PASSWORD >> $CONFIG_FILE
  printf "\"\n" >> $CONFIG_FILE
  printf "}" >> $CONFIG_FILE

  CONFIG=`cat $CONFIG_FILE`

  _out Deploying function: ${FN_SAMPLE_PACKAGE}/function-protected
  ibmcloud wsk action create ${FN_SAMPLE_PACKAGE}/function-protected ${root_folder}/../function-protected/function-protected.js --kind nodejs:10 -a web-export true -p config "${CONFIG}"

  _out Downloading npm modules
  npm --prefix ${root_folder}/text-replace install ${root_folder}/text-replace

  _out Creating swagger-protected.json
  cp ${root_folder}/../function-protected/swagger-template.json ${root_folder}/../function-protected/swagger-protected.json
  #readonly NAMESPACE="${IBMCLOUD_ORG}_${IBMCLOUD_SPACE}"
  
  readonly ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get ${FN_SAMPLE_PACKAGE}/function-protected | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
  #readonly ACTION_URI=$( ibmcloud fn action list | grep "function-protected" | sed "s/^\///" )
  readonly ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
  readonly ACTION_NAME="function-protected"
  readonly ACTION_PRODUCES_EXT="json"
  readonly ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}.${ACTION_PRODUCES_EXT}"

  _out ACTION_NAMESPACE: ${ACTION_NAMESPACE}
  _out ACTION_URL: ${ACTION_URL}
  
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-protected/swagger-protected.json xxx-namespace-xxx ${ACTION_NAMESPACE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-protected/swagger-protected.json xxx-action-url-xxx ${ACTION_URL}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-protected/swagger-protected.json xxx-tenantid-xxx ${APPID_TENANTID}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-protected/swagger-protected.json xxx-sample-package-xxx ${FN_SAMPLE_PACKAGE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-protected/swagger-protected.json xxx-api-basepath-xxx $HIDDEN_API_BASEPATH
  
  _out Deploying API: function-protected
  API_PROTECTED=$(ibmcloud wsk api create --config-file ${root_folder}/../function-protected/swagger-protected.json | awk '/https:/{ print $1 }' )
  _out API_PROTECTED: $API_PROTECTED
  printf "\nAPI_PROTECTED=$API_PROTECTED" >> $ENV_FILE
}

# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export IBMCLOUD_ORG IBMCLOUD_API_KEY BLUEMIX_REGION APPID_TENANTID APPID_OAUTHURL APPID_CLIENTID APPID_SECRET CLOUDANT_USERNAME CLOUDANT_PASSWORD IBMCLOUD_SPACE

_out Full install output in $LOG_FILE
ibmcloud_login
setup
