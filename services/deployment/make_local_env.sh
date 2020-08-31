#!/bin/bash

# ENV_FILE (local.env) may not exist when this is called. 
# For example if we are in a build pipeline, but the resources may still exist.
# Just in case we will look for the top level key and if that exists then
# we will copy over the ENV_FILE read it in and continue from there.
echo "In $0"
root_folder=$(cd $(dirname $0); pwd)
echo "root folder: ${root_folder}"
EXPECTED_VARS="$root_folder/../../local.env"
HAS_PIPELINE_IN_CURRENT_PATH=$(pwd | grep "/home/pipeline/")
echo "HAS_PIPELINE_IN_CURRENT_PATH=${HAS_PIPELINE_IN_CURRENT_PATH}"
ls $root_folder/../../
MISSING_EXPECTED_VARS=0
if [ ! -e "${EXPECTED_VARS}" ]; then
    MISSING_EXPECTED_VARS=1
fi
if [ "x$HOME" == "x/root" ]; then
    echo "HOME was /root"
else
    echo "HOME was not /root, $HOME"
fi

if [ "x$HAS_PIPELINE_IN_CURRENT_PATH" == "x" ]; then
    echo "HAS_PIPELINE_IN_CURRENT_PATH was empty"
else
    echo "HAS_PIPELINE_IN_CURRENT_PATH was not empty ${HAS_PIPELINE_IN_CURRENT_PATH}"
fi

if [ $MISSING_EXPECTED_VARS -gt 0 -a "x$HOME" == "x/root" -a "x$HAS_PIPELINE_IN_CURRENT_PATH" != "x" ]; then
  echo " ** Pipeline detected. ** "
  if [ "x${PROJECT_PREFIX}" == "x" ]; then
    echo "Set variable PROJECT_PREFIX to your project prefix in local.env.template in the pipeline variables."
    exit 1
  fi
  ibm_login.sh
  if [ $? -ne 0 ]; then
    echo "Failed login to IBM Cloud, check logs and try again in a bit"
    exit 1
  fi
  KEY=$(ibmcloud iam api-keys | grep "${PROJECT_PREFIX}" | awk '{print $1}' )
  if [ "x$KEY" == "x" ]; then
    echo "Key not found, assuming no resources exist currently for this project."
    exit 0
  else 
    TEMPLATE="$root_folder/../../local.env.template"
    if [ ! -e "$TEMPLATE" ]; then
      echo "Failed to find local.env template"
      exit 1
    else
      cp "$TEMPLATE" "$EXPECTED_VARS"
      EXP_PROJECT_PREFIX=$(awk -F '-' '{ print $1 }')
      EXP_VERSION=$(awk -F '-' '{ print $2 }')
      echo "Updating version to $EXP_VERSION"
      sed -i "s#^VERSION=.*#VERSION=${EXP_VERSION}#" ${EXPECTED_VARS}
      source $EXPECTED_VARS
      if [ "x$PROJECT_PREFIX" != "x$EXP_PROJECT_PREFIX" ]; then
        echo "Found unexpected project prefix '${PROJECT_PREFIX}'."
        exit 1
      else
        if [ "x$VERSION" != "x$EXP_VERSION" ]; then
          echo "Failed to update version number, found $VERSION expected $EXP_VERSION"
          exit 1
        fi
        echo "VERSION updated and PROJECT_PREFIX matched."
        echo "VERSION: $VERSION"
        echo "PROJECT_PREFIX: $PROJECT_PREFIX"
        echo "PROJECT_NAME: $PROJECT_NAME"
      fi
    fi
  fi
else
    echo "Detected we are not in a pipeline or docker instance"
fi
