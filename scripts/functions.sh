#!/bin/bash

function _out() {
  echo "$@" >&3
  echo "$(date +'%F %H:%M:%S') $@"
}

function _err() {
  echo "$@" >&4
  echo "$(date +'%F %H:%M:%S') $@"
}

function check_tools() {
    MISSING_TOOLS=""
    git --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} git"
    curl --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} curl"
    ibmcloud --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} ibmcloud"    
    if [[ -n "$MISSING_TOOLS" ]]; then
      _err "Some tools (${MISSING_TOOLS# }) could not be found, please install them first and then run scripts/setup-app-id.sh"
      exit 1
    fi
}

function ibmcloud_login() {
  if [ "x${USE_LOGIN}" == "xfalse" ]
  then
    _out Skipping login
    return
  fi
  
  # Skip version check updates
  ibmcloud config --check-version=false
  IBMCLOUD_API_ENDPOINT=$(ibmcloud api | awk '/API endpoint/{print $3}')
  _out IBMCLOUD_API_ENDPOINT=${IBMCLOUD_API_ENDPOINT}

  # Obtain the API endpoint from BLUEMIX_REGION and set it as default
  _out Logging in to IBM cloud
  # Login to ibmcloud, generate .wskprops
  ibmcloud login --apikey $IBMCLOUD_API_KEY -a $IBMCLOUD_API_ENDPOINT -r ${BLUEMIX_REGION}
  if [ $? -ne 0 ]
  then
    _err Failed to login to ibmcloud using api key ${IBMCLOUD_API_KEY}
    exit 1
  fi
  
  ibmcloud target -o "$IBMCLOUD_ORG" -s "$IBMCLOUD_SPACE"
  if [ $? -ne 0 ]
  then
    _err Failed to set target using org ${IBMCLOUD_ORG} and space ${IBMCLOUD_SPACE}
    exit 1
  fi

  RESOURCE_GROUP=$(ibmcloud resource groups | grep -i " active " | head -n 1 | awk '{print $1}')
  _out "Setting resource group to ${RESOURCE_GROUP}"
  ibmcloud target -g $RESOURCE_GROUP
  if [ $? -ne 0 ]
  then
    _err "Failed to set resource group"
    ibmcloud resource groups
    exit 1
  fi

  ibmcloud fn api list > /dev/null

  # Show the result of login to stdout
  ibmcloud target
}

function wait_for_service_to_become_active() {
    _out Waiting on $1 to become active
    while true
    do
        SERVICE_STATE=$( ibmcloud resource service-instance $1 | awk '/State/{print $2}' )
        if [ "x$SERVICE_STATE" == "xactive" ]
        then
            break
        else
            sleep 5
        fi
    done
}