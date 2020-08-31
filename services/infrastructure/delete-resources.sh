#!/bin/bash

source ibm_std_functions.sh
# ENV_FILE (local.env) may not exist when this is called. 
# For example if we are in a build pipeline, but the resources may still exist.
# Just in case we will look for the top level key and if that exists then
# we will copy over the ENV_FILE read it in and continue from there.
root_folder=$(dirname $0; pwd)
EXPECTED_VARS="$root_folder/../../local.env"
if ( ! -e "${EXPECTED_VARS}" && "x$HOME" == "x/root" && grep "/home/pipeline/" <<< $(pwd) ); then
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
fi



standard_project_script_start 
ibmcloud_project_login ${PROJECT_NAME}
root_folder=$(get_root_folder)

_out "Aliases"
SVC_ALIASES=( "${APP_ID_NAME}" )
for svc_alias in ${SVC_ALIASES[@]}
do
  _out "Checking for ${svc_alias}"
  SVC_EXISTS=$(ibmcloud resource service-aliases | grep ${svc_alias})
  if [ "x$SVC_EXISTS" != "x" ]; then
    ibmcloud resource service-alias-delete ${svc_alias} -f
    if [ $? -ne 0 ]; then 
      _fatal "Failed to remove service ${svc_alias}, try manually using the IBM Cloud website."
    else 
      _ok "Deleted alias '${svc_alias}' successfully"
    fi
  fi
done

_out "Service Credentials"
SERVICE_KEYS=( "$CLOUDANT_NAME" "$APP_ID_NAME" "$OBJECT_STORAGE_NAME" )
for skey in ${SERVICE_KEYS[@]}
do
  _out "Checking for ${skey}"
  SVC_EXISTS=$(ibmcloud resource service-keys | grep "${skey}_credentials" )
  if [ "x$SVC_EXISTS" != "x" ]; then
    ibmcloud resource service-key-delete ${skey}_credentials -f
    if [ $? -ne 0 ]; then 
      _fatal "Failed to remove service '${skey}_credentials', try manually using the IBM Cloud website."
    else 
      _ok "Deleted key '${skey}' successfully"
    fi
  fi
done

_out "Service Instances"
SERVICE_INSTANCES=( "$CLOUDANT_NAME" "$APP_ID_NAME" "$OBJECT_STORAGE_NAME" )
for sInst in ${SERVICE_INSTANCES[@]}
do
  _out "Checking for ${sInst}"
  SVC_EXISTS=$(ibmcloud resource service-instances | grep "${sInst}" )
  if [ "x$SVC_EXISTS" != "x" ]; then
    ibmcloud resource service-instance-delete ${sInst} -f
    if [ $? -ne 0 ]; then 
      _fatal "Failed to remove service '${sInst}', try manually using the IBM Cloud website."
    else 
      _ok "Deleted service '${sInst}' successfully"
    fi
  fi
done

_out "Function Namespaces"
FUNCTION_NAMESPACES=( "${FN_NAMESPACE}" )
for svc_ns in ${FUNCTION_NAMESPACES[@]}
do
  _out "Checking for ${svc_ns}"
  SVC_EXISTS=$(ibmcloud fn namespace list | grep "${svc_ns}" )
  if [ "x$SVC_EXISTS" != "x" ]; then
    ibmcloud fn namespace delete ${svc_ns}
    if [ $? -ne 0 ]; then 
      _fatal "Failed to remove namespace '${svc_ns}', try manually using the IBM Cloud website."
    else 
      _ok "Deleted namespace '${svc_ns}' successfully"
    fi
  fi
done

_out "API Keys"
API_KEYS=( "${PROJECT_NAME}" )
for apikey in ${API_KEYS[@]}
do
  _out "Checking for ${apikey}"
  SVC_EXISTS=$(ibmcloud iam api-keys | grep "${apikey}" )
  if [ "x$SVC_EXISTS" != "x" ]; then
    ibmcloud iam api-key-delete ${apikey} -f
    if [ $? -ne 0 ]; then 
      _fatal "Failed to remove namespace '${apikey}', try manually using the IBM Cloud website."
    else 
      _ok "Deleted namespace '${apikey}' successfully"
    fi
  fi
done

_out "Sensitive files"
file_path="${root_folder}/${PROJECT_NAME}.json"
_out "Checking for $(abbreviate_file_path $file_path)"
if [ -e "${file_path}" ]
then
  _out "Deleting $file_path"
  rm -f ${file_path}
  if [ -e "$file_path" ]; then
    _fatal "Failed to remove $file_path"
  else
    _ok "File was deleted successfully"
  fi
fi

