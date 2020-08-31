#!/bin/bash

source ibm_std_functions.sh
standard_project_script_start 
ibmcloud_project_login ${PROJECT_NAME}
if [ $? -ne 0 ]; then
  _out "Failed to login using project key, assuming new instance."
  exit 0
fi
root_folder=$(get_root_folder)

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

