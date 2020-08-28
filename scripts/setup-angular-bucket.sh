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
readonly LOG_FILE="${root_folder}/deploy-angular-bucket.log"
readonly ENV_FILE="${root_folder}/../local.env"
touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh

function build_project() {
  _out Building Angular application
  cd ${root_folder}/../angular
  ng build
}

function modify_project() {
  BUCKET_URL=$1
  
  _out Modify urls in distribution
  npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../angular/dist/index.html src=\" src=\"${BUCKET_URL}
}

function upload_directory() {
  IAM_TOKEN=$1
  BUCKET_URL=$2

  _out Uploading static web application resources
  # Copy up all the files in angular/dist to the storage area
  for local_file in $( find ${root_folder}/../angular/dist -maxdepth 1 -type f )
  do
    base=$(basename "$local_file")
    _out "Uploading angular/dist/${base}"
    curl -X "PUT" "${BUCKET_URL}/${base}" \
        -H "x-amz-acl: public-read" \
        -H "Authorization: Bearer ${IAM_TOKEN}" \
        -H "Content-Type: text/plain; charset=utf-8" \
        --upload-file "${local_file}"
  done
}

function setup() {
  SUFFIX="angular"

  build_project

  _out Creating bucket
  IAM_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $4 }')
  
  COS_ID=$(ibmcloud resource service-instance ${OBJECT_STORAGE} --id | awk '/crn/{ print $2 }')
  _out COS_ID: $COS_ID
  printf "\nCOS_ID=$COS_ID" >> $ENV_FILE
  
  # if we get bucket already exists, change this and it will change it throughout
  _out BUCKET_NAME: ${angular_BUCKET_NAME}
  
  OBJECT_URL="cloud-object-storage.appdomain.cloud"
  BUCKET_URL="https://s3.${BLUEMIX_REGION}.${OBJECT_URL}/${angular_BUCKET_NAME}"
  _out BUCKET_URL: $BUCKET_URL
  COS_URL_HOME_BASE=${BUCKET_URL}
  COS_URL_HOME="${COS_URL_HOME_BASE}/index.html"
  printf "\n${SUFFIX}_COS_URL_HOME=$COS_URL_HOME" >> $ENV_FILE
  printf "\n${SUFFIX}_COS_URL_HOME_BASE=$COS_URL_HOME_BASE" >> $ENV_FILE

  modify_project ${BUCKET_URL}

  upload_directory ${IAM_TOKEN} ${BUCKET_URL}
}

# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "ensure you are running via the build_all.sh scripts"
  exit 1
fi
source $ENV_FILE
export IBMCLOUD_ORG IBMCLOUD_API_KEY BLUEMIX_REGION APPID_TENANTID APPID_OAUTHURL APPID_CLIENTID APPID_SECRET 
export CLOUDANT_USERNAME CLOUDANT_PASSWORD IBMCLOUD_SPACE
export angular_BUCKET_NAME

_out Full install output in $LOG_FILE
ibmcloud_login
setup

