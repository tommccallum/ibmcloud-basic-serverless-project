#!/bin/bash

source ibm_utility_functions.sh
standard_project_script_start

WORKLOAD="$1"

if [ "x$WORKLOAD" == "x" ]; then
  bump_version "local.env.template"
  cp local.env.template local.env
  source local.env
  _out "Using version ${VERSION}"
  create_new_project_key ${PROJECT_NAME}
  
  # source local.env.template
  # VERSION=$((VERSION + 1))
  # sed -i "s/VERSION=[0-9]*/VERSION=${VERSION}/" local.env.template

  # echo "Restoring local.env"
  # cp local.env.template local.env
  # IBMCLOUD_ORG=$(ibmcloud target | awk '/Org/{print $2}')
  # IBMCLOUD_SPACE=$(ibmcloud target | awk '/Space/{print $2}')
  # BLUEMIX_REGION=$(ibmcloud target | awk '/Region/{print $2}')
  # echo "IBMCLOUD_ORG=\"${IBMCLOUD_ORG}\"" >>local.env
  # echo "IBMCLOUD_SPACE=\"${IBMCLOUD_SPACE}\"" >>local.env
  # echo "BLUEMIX_REGION=\"${BLUEMIX_REGION}\"" >>local.env
  # echo "FUNCTION_PUBLIC_URL=\"https://${BLUEMIX_REGION}.functions.appdomain.cloud/api/v1/web\"" >>local.env

  # source local.env
  # echo "Using version ${VERSION}"

  # echo "Creating new API key for project"
  # API_KEY_FILE="${PROJECT_NAME}.json"
  # ibmcloud iam api-key-create ${PROJECT_NAME} -d "${PROJECT} version ${VERSION}" --file ${API_KEY_FILE}
  # IBMCLOUD_API_KEY=$(grep "\"apikey" $API_KEY_FILE | awk '{print $2}' | sed "s/[\",]//g")
  # echo "IBMCLOUD_API_KEY: ${IBMCLOUD_API_KEY}"
  # sed -i "/IBMCLOUD_API_KEY=/d" local.env
  # echo "IBMCLOUD_API_KEY=${IBMCLOUD_API_KEY}" >>local.env

  # source local.env
  # echo "Starting resource creation ${IBMCLOUD_API_KEY}"
  rm -f scripts/*.log
  run scripts/setup-app-id.sh
  run scripts/setup-cloudant.sh
  run scripts/setup-login-function.sh
  run scripts/setup-private-actions.sh
  run scripts/setup-object-storage.sh
  run scripts/setup-buckets.sh
  run scripts/setup-angular-webapp.sh
  run scripts/setup-angular-bucket.sh
fi

if [ "x${WORKLOAD}" == "x" -o "x${WORKLOAD}" == "xpublic" ]; then
  run scripts/setup-public-actions.sh
  run scripts/setup-demo-function.sh
  run scripts/setup-public-api.sh
  run scripts/setup-finale.sh
fi
