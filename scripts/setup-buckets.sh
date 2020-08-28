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
readonly LOG_FILE="${root_folder}/deploy-buckets.log"
readonly ENV_FILE="${root_folder}/../local.env"
touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh

function setup() {
  SUFFIX=$1
  if [ "x$SUFFIX" == "x" ]
  then
    _err "Framework name cannot be empty when creating buckets"
    exit 1
  fi

  _out Creating bucket for ${SUFFIX}
  IAM_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $4 }')
  
  # if we get bucket already exists, change this and it will change it throughout
  BUCKET_NAME="${BUCKET_PREFIX}-${APPID_TENANTID}-${SUFFIX}"
  _out BUCKET_NAME: $BUCKET_NAME
  printf "\n${SUFFIX}_BUCKET_NAME=$BUCKET_NAME" >> $ENV_FILE
  ibmcloud cos create-bucket --bucket "${BUCKET_NAME}" --ibm-service-instance-id ${COS_ID} --region ${BLUEMIX_REGION}
  if [ $? -ne 0 ]
  then
    _err Failed to create new bucket called ${BUCKET_NAME}
  fi

  
}

# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export IBMCLOUD_ORG IBMCLOUD_API_KEY BLUEMIX_REGION APPID_TENANTID APPID_OAUTHURL APPID_CLIENTID 
export APPID_SECRET CLOUDANT_USERNAME CLOUDANT_PASSWORD IBMCLOUD_SPACE COS_ID

_out Full install output in $LOG_FILE
ibmcloud_login
for fw in ${FRAMEWORKS[@]}
do
  setup $fw
done

