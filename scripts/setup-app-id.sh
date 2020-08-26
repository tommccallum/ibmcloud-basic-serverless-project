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
#
# Authors: Andrea Frittoli, Niklas Heidloff
##############################################################################

##############################################################################
# Updated and factored some of these scripts for our use case.
# Heavily edited by: Tom McCallum
##############################################################################

root_folder=$(cd $(dirname $0); pwd)

# SETUP logging (redirect stdout and stderr to a log file)
readonly LOG_FILE="${root_folder}/deploy-app-id.log"
readonly ENV_FILE="${root_folder}/../local.env"
touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh



function setup() {
  _out Creating App ID service instance
  RESOURCE_GROUP=$(ibmcloud target | awk '/Resource group:/{ print $2 }')
  if [ "x$RESOURCE_GROUP" == "x" ]
  then
    _out Setting resource group to Default
    ibmcloud target "Default"
  fi
  ibmcloud resource service-instance-create ${APP_ID} appid lite $BLUEMIX_REGION
  
  wait_for_service_to_become_active ${APP_ID}
  
  # TODO check if this resource alias exists and delete otherwise don't
  # the problem is it creates an extra FAILED flag in our logs
  ALIAS_EXISTS=$( ibmcloud resource service-aliases | grep ${APP_ID} | wc -l )
  if [ ${ALIAS_EXISTS} -gt 0 ]
  then
    _out Deleting existing alias: ${APP_ID}
    ibmcloud resource service-alias-delete ${APP_ID} -f
  fi
  _out Creating alias: ${APP_ID}
  ibmcloud resource service-alias-create ${APP_ID} --instance-name ${APP_ID}

  _out Creating App ID credentials
  ibmcloud resource service-key-create ${APP_ID}-credentials Reader --instance-name ${APP_ID}
  ibmcloud resource service-key ${APP_ID}-credentials
  APPID_MGMTURL=$(ibmcloud resource service-key ${APP_ID}-credentials | awk '/managementUrl/{ print $2 }')
  _out APPID_MGMTURL: $APPID_MGMTURL
  printf "\nAPPID_MGMTURL=$APPID_MGMTURL" >> $ENV_FILE
  APPID_TENANTID=$(ibmcloud resource service-key ${APP_ID}-credentials | awk '/tenantId/{ print $2 }')
  _out APPID_TENANTID: $APPID_TENANTID
  printf "\nAPPID_TENANTID=$APPID_TENANTID" >> $ENV_FILE
  APPID_OAUTHURL=$(ibmcloud resource service-key ${APP_ID}-credentials | awk '/oauthServerUrl/{ print $2 }')
  _out APPID_OAUTHURL: $APPID_OAUTHURL
  printf "\nAPPID_OAUTHURL=$APPID_OAUTHURL" >> $ENV_FILE
  APPID_CLIENTID=$(ibmcloud resource service-key ${APP_ID}-credentials | awk '/clientId/{ print $2 }')
  _out APPID_CLIENTID: $APPID_CLIENTID
  printf "\nAPPID_CLIENTID=$APPID_CLIENTID" >> $ENV_FILE
  APPID_SECRET=$(ibmcloud resource service-key ${APP_ID}-credentials | awk '/secret/{ print $2 }')
  _out APPID_SECRET: $APPID_SECRET
  printf "\nAPPID_SECRET=$APPID_SECRET" >> $ENV_FILE
  
  DEMO_EMAIL=user@demo.email
  DEMO_PASSWORD=verysecret
  _out Creating cloud directory test user: $DEMO_EMAIL, $DEMO_PASSWORD
  IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
  curl -s -X POST \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"emails": [
            {"value": "'$DEMO_EMAIL'","primary": true}
          ],
         "userName": "'$DEMO_EMAIL'",
         "password": "'$DEMO_PASSWORD'"
        }' \
    "${APPID_MGMTURL}/cloud_directory/Users"
}


# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export TF_VAR_ibm_bx_api_key=$IBMCLOUD_API_KEY
export TF_VAR_ibm_cf_org=$IBMCLOUD_ORG
export TF_VAR_ibm_cf_space=$IBMCLOUD_SPACE
export IBMCLOUD_API_KEY BLUEMIX_REGION
export TF_VAR_appid_plan=${IBMCLOUD_APPID_PLAN:-"lite"}
export TF_VAR_cloudant_plan=${IBMCLOUD_CLOUDANT_PLAN:-"Lite"}

_out Full install output in $LOG_FILE
ibmcloud_login
setup $@

