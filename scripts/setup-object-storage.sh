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
readonly LOG_FILE="${root_folder}/deploy-object-storage.log"
readonly ENV_FILE="${root_folder}/../local.env"
touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh

function setup() {
  _out Creating Object Storage service instance
  ibmcloud resource service-instance-create ${OBJECT_STORAGE} cloud-object-storage lite global
  
  wait_for_service_to_become_active ${OBJECT_STORAGE}
  
  _out Creating Object Storage credentials
  ibmcloud resource service-key-create ${OBJECT_STORAGE}-credentials Reader --instance-name ${OBJECT_STORAGE}
  
  _out Creating bucket
  IAM_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $4 }')
  
  COS_ID=$(ibmcloud resource service-instance ${OBJECT_STORAGE} --id | awk '/crn/{ print $2 }')
  _out COS_ID: $COS_ID
  printf "\nCOS_ID=$COS_ID" >> $ENV_FILE
  
  #_out Set crn in cos config
  #ibmcloud cos config crn --crn $COS_ID
  
  # if we get bucket already exists, change this and it will change it throughout
  BUCKET_NAME="${BUCKET_PREFIX}-${APPID_TENANTID}"
  _out BUCKET_NAME: $BUCKET_NAME
  printf "\nBUCKET_NAME=$BUCKET_NAME" >> $ENV_FILE
  ibmcloud cos create-bucket --bucket "${BUCKET_NAME}" --ibm-service-instance-id ${COS_ID} --region ${BLUEMIX_REGION}
  if [ $? -ne 0 ]
  then
    _err Failed to create new bucket called ${BUCKET_NAME}
  fi
#   curl -X "PUT" "https://s3.us-south.objectstorage.softlayer.net/${BUCKET_NAME}" \
#     -H "Authorization: Bearer ${IAM_TOKEN}" \
#     -H "ibm-service-instance-id: ${COS_ID}"

    
  _out Building Angular application
  cd ${root_folder}/../angular
  ng build

  #npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../angular/dist/index.html src=\" src=\"https://s3.${BLUEMIX_REGION}.objectstorage.softlayer.net/${BUCKET_NAME}/
  OBJECT_URL="cloud-object-storage.appdomain.cloud"
  BUCKET_URL="https://s3.${BLUEMIX_REGION}.${OBJECT_URL}/${BUCKET_NAME}"
  _out BUCKET_URL: $BUCKET_URL
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../angular/dist/index.html src=\" src=\"${BUCKET_URL}

  _out Uploading static web application resources
  curl -X "PUT" "${BUCKET_URL}/index.html" \
    -H "x-amz-acl: public-read" \
    -H "Authorization: Bearer ${IAM_TOKEN}" \
    -H "Content-Type: text/html; charset=utf-8" \
    --upload-file "${root_folder}/../angular/dist/index.html"

  curl -X "PUT" "${BUCKET_URL}/inline.bundle.js" \
    -H "x-amz-acl: public-read" \
    -H "Authorization: Bearer ${IAM_TOKEN}" \
    -H "Content-Type: text/plain; charset=utf-8" \
    --upload-file "${root_folder}/../angular/dist/inline.bundle.js"

  curl -X "PUT" "${BUCKET_URL}/polyfills.bundle.js" \
     -H "x-amz-acl: public-read" \
     -H "Authorization: Bearer ${IAM_TOKEN}" \
     -H "Content-Type: text/plain; charset=utf-8" \
     --upload-file "${root_folder}/../angular/dist/polyfills.bundle.js"

  curl -X "PUT" "${BUCKET_URL}/styles.bundle.js" \
     -H "x-amz-acl: public-read" \
     -H "Authorization: Bearer ${IAM_TOKEN}" \
     -H "Content-Type: text/plain; charset=utf-8" \
     --upload-file "${root_folder}/../angular/dist/styles.bundle.js"

  curl -X "PUT" "${BUCKET_URL}/main.bundle.js" \
     -H "x-amz-acl: public-read" \
     -H "Authorization: Bearer ${IAM_TOKEN}" \
     -H "Content-Type: text/plain; charset=utf-8" \
     --upload-file "${root_folder}/../angular/dist/main.bundle.js"

  curl -X "PUT" "${BUCKET_URL}/vendor.bundle.js" \
     -H "x-amz-acl: public-read" \
     -H "Authorization: Bearer ${IAM_TOKEN}" \
     -H "Content-Type: text/plain; charset=utf-8" \
     --upload-file "${root_folder}/../angular/dist/vendor.bundle.js"

  COS_URL_HOME_BASE=${BUCKET_URL}
  COS_URL_HOME="${COS_URL_HOME_BASE}/index.html"
  printf "\nCOS_URL_HOME=$COS_URL_HOME" >> $ENV_FILE
  printf "\nCOS_URL_HOME_BASE=$COS_URL_HOME_BASE" >> $ENV_FILE

  _out You can now open index.html but the app does not work yet: ${COS_URL_HOME}
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
