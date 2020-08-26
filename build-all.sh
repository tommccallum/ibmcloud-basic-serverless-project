#!/bin/bash

function run() {
  $1

  ERROR_COUNT=$( grep "FAILED" scripts/*.log | wc -l )
  if [ $ERROR_COUNT -gt 0 ]
  then
    echo -e "\e[1;31m[$1] $ERROR_COUNT errors found\e[0m"
    grep -nH "FAILED" scripts/*.log
    exit 1
  else
    echo -e "\e[1;32m[$1] Completed successful\e[0m"
  fi
}

MODIFIED=$( grep "APPID_MGMTURL" local.env | wc -l )
if [ $MODIFIED -eq 0 ]
then
  echo "Saving local.env"
  cp local.env local.env.bak
else
  source local.env.bak
  VERSION=$((VERSION+1))
  sed -i "s/VERSION=[0-9]*/VERSION=${VERSION}/" local.env.bak

  echo "Restoring local.env"
  cp local.env.bak local.env
fi
source local.env
echo "Using version ${VERSION}"

echo "Creating new API key for project"
API_KEY_FILE="${PROJECT_NAME}.json"
ibmcloud iam api-key-create ${PROJECT_NAME} -d "${PROJECT} version ${VERSION}" --file ${API_KEY_FILE}
IBMCLOUD_API_KEY=$(grep "\"apikey" $API_KEY_FILE | awk '{print $2}' | sed "s/[\",]//g" )
echo "IBMCLOUD_API_KEY: ${IBMCLOUD_API_KEY}"
sed -i "/IBMCLOUD_API_KEY=/d" local.env
echo "IBMCLOUD_API_KEY=${IBMCLOUD_API_KEY}" >> local.env

source local.env
echo "Starting resource creation ${IBMCLOUD_API_KEY}"
rm -f scripts/*.log
run scripts/setup-app-id.sh
run scripts/setup-cloudant.sh
run scripts/setup-login-function.sh
run scripts/setup-protected-function.sh
run scripts/setup-local-webapp.sh
run scripts/setup-object-storage.sh
run scripts/setup-html-function.sh

