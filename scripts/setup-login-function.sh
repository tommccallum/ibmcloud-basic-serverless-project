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
readonly LOG_FILE="${root_folder}/deploy-login-function.log"
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
  
  _out Preparing deployment of two functions and a sequence
  _out Creating package: ${FN_GENERIC_PACKAGE}
  ibmcloud wsk package create ${FN_GENERIC_PACKAGE}

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
  printf "http://localhost:4200" >> $CONFIG_FILE
  printf "\"\n" >> $CONFIG_FILE
  printf "}" >> $CONFIG_FILE

  CONFIG=`cat $CONFIG_FILE`

  _out Deploying function: ${FN_GENERIC_PACKAGE}/login
  ibmcloud wsk action create ${FN_GENERIC_PACKAGE}/login ${root_folder}/../function-login/login.js --kind nodejs:10 -p config "${CONFIG}"

  _out Deploying function: ${FN_GENERIC_PACKAGE}/redirect
  ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/redirect ${root_folder}/../function-login/redirect.js --kind nodejs:10 -a web-export true -p config "${CONFIG}"

  _out Deploying sequence: ${FN_GENERIC_PACKAGE}/login-and-redirect
  ibmcloud wsk action update --sequence ${FN_GENERIC_PACKAGE}/login-and-redirect ${FN_GENERIC_PACKAGE}/login,${FN_GENERIC_PACKAGE}/redirect -a web-export true 

  _out Downloading npm modules
  npm --prefix ${root_folder}/text-replace install ${root_folder}/text-replace

  _out Creating swagger-login.json
  cp ${root_folder}/../function-login/swagger-template.json ${root_folder}/../function-login/swagger-login.json
  
  readonly ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get ${FN_GENERIC_PACKAGE}/login-and-redirect | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
  readonly ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
  readonly ACTION_URI=$( ibmcloud fn action list | grep "login-and-redirect" | awk '{print $1}' | sed "s/^\///" )
  readonly NAMESPACE="${ACTION_NAMESPACE}"
  readonly ACTION_NAME="login-and-redirect"
  readonly ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}"

  _out ACTION_NAMESPACE: $ACTION_NAMESPACE
  _out ACTION_URL: $ACTION_URL
  
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-namespace-xxx ${NAMESPACE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-generic-package-xxx ${FN_GENERIC_PACKAGE}
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-action-url-xxx $ACTION_URL
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-api-basepath-xxx $LOGIN_API_BASEPATH
  
  _out Deploying API: login
  API_LOGIN=$(ibmcloud wsk api create --config-file ${root_folder}/../function-login/swagger-login.json | awk '/https:/{ print $1 }')
  _out API_LOGIN: $API_LOGIN
  printf "\nAPI_LOGIN=$API_LOGIN" >> $ENV_FILE

  _out Updating function: ${FN_GENERIC_PACKAGE}/login
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
  printf "http://localhost:4200" >> $CONFIG_FILE
  printf "\",\n" >> $CONFIG_FILE
  printf "\"redirect_uri\": \"" >> $CONFIG_FILE
  printf $API_LOGIN >> $CONFIG_FILE
  printf "\"\n" >> $CONFIG_FILE
  printf "}" >> $CONFIG_FILE
  CONFIG=`cat $CONFIG_FILE`
  ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/login ${root_folder}/../function-login/login.js --kind nodejs:10 -p config "${CONFIG}"

  _out Creating redirect URL in App ID: $API_LOGIN
  IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
  curl -s -X PUT \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"redirectUris": [
            "'$API_LOGIN'", "http://ibm.biz/login-nh"
          ]
        }' \
    "${APPID_MGMTURL}/config/redirect_uris"
}

# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export IBMCLOUD_ORG IBMCLOUD_API_KEY BLUEMIX_REGION APPID_TENANTID APPID_OAUTHURL APPID_CLIENTID APPID_SECRET CLOUDANT_USERNAME CLOUDANT_PASSWORD IBMCLOUD_SPACE APPID_MGMTURL

_out Full install output in $LOG_FILE
ibmcloud_login
setup
