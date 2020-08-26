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
readonly LOG_FILE="${root_folder}/deploy-html-function.log"
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
  
  _out Deploying function ${FN_SAMPLE_PACKAGE=}/html
  
  _out COS_URL_HOME_BASE=${COS_URL_HOME_BASE}
  cp ${root_folder}/../function-html/function-html.template.js ${root_folder}/../function-html/function-html.js
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-html/function-html.js xxx-replace-me-xxx $COS_URL_HOME_BASE

  ibmcloud wsk action create ${FN_SAMPLE_PACKAGE}/html ${root_folder}/../function-html/function-html.js --kind nodejs:10 -a web-export true

  _out Deploying API: function-html
  ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get ${FN_SAMPLE_PACKAGE}/html | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
  ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
  ACTION_NAME="html"
  ACTION_PRODUCES_EXT="html"
  
  #readonly NAMESPACE="${IBMCLOUD_ORG}_${IBMCLOUD_SPACE}"
  readonly NAMESPACE="${ACTION_NAMESPACE}"
  readonly ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}.${ACTION_PRODUCES_EXT}"

  _out ACTION_NAMESPACE: $NAMESPACE
  _out ACTION_URL: $ACTION_URL

  cp ${root_folder}/../function-html/swagger-template.json ${root_folder}/../function-html/swagger.json
  
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-html/swagger.json xxx-namespace-xxx ${NAMESPACE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-html/swagger.json xxx-action-url-xxx $ACTION_URL
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-html/swagger.json xxx-sample-package-xxx ${FN_SAMPLE_PACKAGE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-html/swagger.json xxx-api-basepath-xxx $API_BASEPATH
  
  
  API_HOME=$(ibmcloud wsk api create --config-file ${root_folder}/../function-html/swagger.json | awk '/https:/{ print $1 }')
  _out API_HOME: $API_HOME
  printf "\nAPI_HOME=$API_HOME" >> $ENV_FILE

 _out Updating function: ${FN_GENERIC_PACKAGE}/redirect
  readonly CONFIG_FILE="${root_folder}/../function-login/config.json"
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
  printf $API_HOME >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"redirect_uri\": \"" >> $CONFIG_FILE
  printf $API_LOGIN >> $CONFIG_FILE
  printf "\"\n" >> $CONFIG_FILE
  printf "}" >> $CONFIG_FILE
  CONFIG=`cat $CONFIG_FILE`
  
  
  ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/redirect ${root_folder}/../function-login/redirect.js --kind nodejs:10 -a web-export true -p config "${CONFIG}"

  _out Done! Open your app: ${API_HOME}
}



# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export IBMCLOUD_API_KEY BLUEMIX_REGION APPID_TENANTID APPID_OAUTHURL APPID_CLIENTID APPID_SECRET CLOUDANT_USERNAME CLOUDANT_PASSWORD COS_URL_HOME COS_URL_HOME_BASE API_HOME

_out Full install output in $LOG_FILE
ibmcloud_login
setup
