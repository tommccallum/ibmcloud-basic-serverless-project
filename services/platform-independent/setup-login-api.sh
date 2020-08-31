#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

root_folder=$(get_root_folder)
readonly TEMPLATE_PATH="${root_folder}/../../function-login/swagger-template.json"
if [ ! -e "$TEMPLATE_PATH" ]; then
    _fatal "Template '$TEMPLATE_PATH' does not exist."
fi
readonly REAL_PATH="${root_folder}/../../function-login/swagger-login.json"
if [ -e "$REAL_PATH" ]; then
    rm "${REAL_PATH}"
fi
cp "${TEMPLATE_PATH}" "${REAL_PATH}"

readonly ACTION_NAME="login-and-redirect"
readonly FULL_ACTION_NAME="${FN_GENERIC_PACKAGE}/${ACTION_NAME}"
readonly ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get "${FULL_ACTION_NAME}" | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
if [ "x${ACTION_NAMESPACE_AND_PACKAGE}" == "x" ]; then
    _err "Failed to get namespace and package for action ${FULL_ACTION_NAME}"
    ibmcloud fn action get "${FULL_ACTION_NAME}"
    _fatal
fi
readonly ACTION_NAMESPACE=$( echo "${ACTION_NAMESPACE_AND_PACKAGE}" | awk -F '/' '{print $1}' )
if [ "x${ACTION_NAMESPACE}" == "x" ]; then
    _fatal "Failed to get namespace for action ${FULL_ACTION_NAME}"
fi
readonly ACTION_URL="${FUNCTION_PUBLIC_URL}/${ACTION_NAMESPACE_AND_PACKAGE}/${ACTION_NAME}"

_out ACTION_NAMESPACE: $ACTION_NAMESPACE
_out ACTION_URL: $ACTION_URL
  
sed -i "s#xxx-namespace-xxx#${ACTION_NAMESPACE}#" "${REAL_PATH}" 
sed -i "s#xxx-generic-package-xxx#${FN_GENERIC_PACKAGE}#" "${REAL_PATH}"  
sed -i "s#xxx-action-url-xxx#${ACTION_URL}#" "${REAL_PATH}"  
sed -i "s#xxx-api-basepath-xxx#${LOGIN_API_BASEPATH}#" "${REAL_PATH}"  
  
_out Deploying API: login
API_LOGIN=$(ibmcloud wsk api create --config-file "${REAL_PATH}" | awk '/https:/{ print $1 }')
if [ "x${API_LOGIN}" == "x" ]; then
    _fatal "Unable to create api"
fi
_out API_LOGIN: $API_LOGIN
set_var_in_env "API_LOGIN" ${API_LOGIN}

_out Updating function: ${FN_GENERIC_PACKAGE}/login
APPID_CLIENTID=$(app_id_get_client_id "${APP_ID_NAME}")
if [ "x$APPID_CLIENTID" == "x" ]; then
    _fatal "App ID Client ID was empty, check App ID details."
fi
APPID_SECRET=$(app_id_get_secret "${APP_ID_NAME}")
if [ "x$APPID_SECRET" == "x" ]; then
    _fatal "App ID Secret was empty, check App ID details."
fi
APPID_OAUTHURL=$(app_id_get_oauth_server_url "${APP_ID_NAME}")
if [ "x$APPID_OAUTHURL" == "x" ]; then
    _fatal "App ID OAuth url was empty, check App ID details."
fi

_out Write configuration for login
readonly CONFIG_FILE="${root_folder}/../../function-login/config.json"
if [ ! -e "${CONFIG_FILE}" ]; then
    _fatal "Could not find '${CONFIG_FILE}'"
fi
rm $CONFIG_FILE
touch $CONFIG_FILE
printf "{\n" >> $CONFIG_FILE
printf "\"client_id\": \"" >> $CONFIG_FILE
printf $APPID_CLIENTID >> $CONFIG_FILE
printf "\",\n" >> $CONFIG_FILE
printf "\"client_secret\": \"" >> $CONFIG_FILE
printf $APPID_SECRET >> $CONFIG_FILE
printf "\",\n" >> $CONFIG_FILE
printf "\"oauth_url\": \"" >> $CONFIG_FILE
printf $APPID_OAUTHURL >> $CONFIG_FILE
printf "\",\n" >> $CONFIG_FILE
printf "\"webapp_redirect\": \"" >> $CONFIG_FILE
printf "http://localhost:4200" >> $CONFIG_FILE
printf "\",\n" >> $CONFIG_FILE
printf "\"redirect_uri\": \"" >> $CONFIG_FILE
printf $API_LOGIN >> $CONFIG_FILE
printf "\"\n" >> $CONFIG_FILE
printf "}" >> $CONFIG_FILE
CONFIG=`cat $CONFIG_FILE`

_out Update config for "${FN_GENERIC_PACKAGE}/login"
readonly action_js="${root_folder}/../../function-login/login.js"
args="-p config \"${CONFIG}\""
update_function_action "${FN_GENERIC_PACKAGE}/login" "$action_js" "${NODE_VERSION}" ${args}

login_action_name="${FN_GENERIC_PACKAGE}/login"
login_action_js="${root_folder}/../../function-login/login.js"
pre_check_for_function_action "$login_action_name" "$login_action_js" "${NODE_VERSION}"
if [ $? -eq 2 ]; then
    ibmcloud wsk action update "$login_action_name" "$login_action_js" --kind "${NODE_VERSION}" -p config "${CONFIG}"
    if [ $? -ne 0 ]; then
        _fatal "Could not update function action '${login_action_name}'"
    else 
        _ok "${login_action_name} updated successfully"
    fi
else
    _fatal "function action '${login_action_name}' missing, update failed"
fi