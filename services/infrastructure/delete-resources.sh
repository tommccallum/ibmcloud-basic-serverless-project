#!/bin/bash

source ibm_std_functions.sh
standard_project_script_start 
ibmcloud_project_login ${PROJECT_NAME}
if [ $? -ne 0 ]; then
  _out "Failed to login using project key, assuming new instance."
  exit 0
fi
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

# _out "API Keys"
# API_KEYS=( "${PROJECT_NAME}" )
# for apikey in ${API_KEYS[@]}
# do
#   _out "Checking for ${apikey}"
#   SVC_EXISTS=$(ibmcloud iam api-keys | grep "${apikey}" )
#   if [ "x$SVC_EXISTS" != "x" ]; then
#     ibmcloud iam api-key-delete ${apikey} -f
#     if [ $? -ne 0 ]; then 
#       _fatal "Failed to remove namespace '${apikey}', try manually using the IBM Cloud website."
#     else 
#       _ok "Deleted namespace '${apikey}' successfully"
#     fi
#   fi
# done

# _out "Sensitive files"
# file_path="${root_folder}/${PROJECT_NAME}.json"
# _out "Checking for $(abbreviate_file_path $file_path)"
# if [ -e "${file_path}" ]
# then
#   _out "Deleting $file_path"
#   rm -f ${file_path}
#   if [ -e "$file_path" ]; then
#     _fatal "Failed to remove $file_path"
#   else
#     _ok "File was deleted successfully"
#   fi
# fi

