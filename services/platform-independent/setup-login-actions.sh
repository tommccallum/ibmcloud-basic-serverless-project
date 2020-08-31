#!/bin/bash

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

set_default_function_namespace ${FN_NAMESPACE}
if [ $? -ne 0 ]; then
    _err "Failed to set default namespace ${FN_NAMESPACE}"
    ibmcloud fn namespace list
    _fatal
fi
create_function_package ${FN_GENERIC_PACKAGE}
root_folder=$(get_root_folder)

readonly APPID_CLIENTID=$(app_id_get_client_id "${APP_ID_NAME}")
if [ "x$APPID_CLIENTID" == "x" ]; then
    _fatal "App ID Client ID was empty, check App ID details."
fi
readonly APPID_SECRET=$(app_id_get_secret "${APP_ID_NAME}")
if [ "x$APPID_SECRET" == "x" ]; then
    _fatal "App ID Secret was empty, check App ID details."
fi
readonly APPID_OAUTHURL=$(app_id_get_oauth_server_url "${APP_ID_NAME}")
if [ "x$APPID_OAUTHURL" == "x" ]; then
    _fatal "App ID OAuth url was empty, check App ID details."
fi
readonly CONFIG_FILE="${root_folder}/../../function-login/config.json"
if [ -e "${CONFIG_FILE}" ]; then
    rm $CONFIG_FILE
fi
touch $CONFIG_FILE

printf "{" >> $CONFIG_FILE
printf "\"client_id\": \"" >> $CONFIG_FILE
printf $APPID_CLIENTID >> $CONFIG_FILE
printf "\"," >> $CONFIG_FILE
printf "\"client_secret\": \"" >> $CONFIG_FILE
printf $APPID_SECRET >> $CONFIG_FILE
printf "\"," >> $CONFIG_FILE
printf "\"oauth_url\": \"" >> $CONFIG_FILE
printf $APPID_OAUTHURL >> $CONFIG_FILE
printf "\"," >> $CONFIG_FILE
printf "\"webapp_redirect\": \"" >> $CONFIG_FILE
printf "http://localhost:4200" >> $CONFIG_FILE
printf "\"" >> $CONFIG_FILE
printf "}" >> $CONFIG_FILE

CONFIG=`cat $CONFIG_FILE`


login_action_name="${FN_GENERIC_PACKAGE}/login"
login_action_js="${root_folder}/../../function-login/login.js"
pre_check_for_function_action "$login_action_name" "$login_action_js" "${NODE_VERSION}"
if [ $? -eq 0 ]; then
    ibmcloud wsk action create "$login_action_name" "$login_action_js" --kind "${NODE_VERSION}" -p config "${CONFIG}"
    if [ $? -ne 0 ]; then
        _fatal "create_function_action: Could not create function action '${login_action_name}'"
    else 
        _ok "${login_action_name} was created successfully."
    fi
fi

redirect_action_name="${FN_GENERIC_PACKAGE}/redirect"
redirect_action_js="${root_folder}/../../function-login/redirect.js"
pre_check_for_function_action "$redirect_action_name" "$redirect_action_js" "${NODE_VERSION}"
if [ $? -eq 0 ]; then
    ibmcloud wsk action create "$redirect_action_name" "$redirect_action_js" --kind "${NODE_VERSION}" -a web-export true -p config '${CONFIG}'
    if [ $? -ne 0 ]; then
        _fatal "create_function_action: Could not create function action '${redirect_action_name}'"
    else 
        _ok "${redirect_action_name} was created successfully."
    fi
fi


seq_name="${FN_GENERIC_PACKAGE}/login-and-redirect"
sequence="${login_action_name},${redirect_action_name}"
pre_check_for_function_sequence "$seq_name" "$sequence" 
if [ $? -eq 0 ]; then
    ibmcloud wsk action create --sequence "$seq_name" "$sequence" -a web-export true 
    if [ $? -ne 0 ]; then
        _fatal "create_function_action: Could not create function action '${seq_name}'"
    else 
        _ok "${seq_name} was created successfully."
    fi
fi


# function setup() {
#   NS_EXISTS=$( ibmcloud fn namespace get ${FN_NAMESPACE} | grep "Entities in namespace" )
#   if [ "x$NS_EXISTS" == "x" ]
#   then
#     _out Setting namespace for protected function
#     ibmcloud fn namespace create ${FN_NAMESPACE} --description "Serverless Web App Sample"
#   fi
  
#   ibmcloud fn property set --namespace ${FN_NAMESPACE}
  
#   _out Preparing deployment of two functions and a sequence
#   _out Creating package: ${FN_GENERIC_PACKAGE}
#   ibmcloud wsk package create ${FN_GENERIC_PACKAGE}

#   save_config_for_login

#   _out Deploying function: ${FN_GENERIC_PACKAGE}/login
#   ibmcloud wsk action create ${FN_GENERIC_PACKAGE}/login ${root_folder}/../function-login/login.js --kind nodejs:10 -p config "${CONFIG}"

#   _out Deploying function: ${FN_GENERIC_PACKAGE}/redirect
#   ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/redirect ${root_folder}/../function-login/redirect.js --kind nodejs:10 -a web-export true -p config "${CONFIG}"

#   _out Deploying sequence: ${FN_GENERIC_PACKAGE}/login-and-redirect
#   ibmcloud wsk action update --sequence ${FN_GENERIC_PACKAGE}/login-and-redirect ${FN_GENERIC_PACKAGE}/login,${FN_GENERIC_PACKAGE}/redirect -a web-export true 

#   _out Downloading npm modules
#   npm --prefix ${root_folder}/text-replace install ${root_folder}/text-replace

#   _out Creating swagger-login.json
#   cp ${root_folder}/../function-login/swagger-template.json ${root_folder}/../function-login/swagger-login.json
  
#   readonly ACTION_NAMESPACE_AND_PACKAGE=$( ibmcloud fn action get ${FN_GENERIC_PACKAGE}/login-and-redirect | awk '/namespace/{print $2}' | sed "s/,//" | sed "s/\"//g" )
#   readonly ACTION_NAMESPACconfig
#   _out ACTION_NAMESPACE: $ACTION_NAMESPACE
#   _out ACTION_URL: $ACTION_URL
  
#   npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-namespace-xxx ${NAMESPACE}
#   npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-generic-package-xxx ${FN_GENERIC_PACKAGE}
#   npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-action-url-xxx $ACTION_URL
#   npm --prefix ${root_folder}/text-replace start ${root_folder}/text-replace ${root_folder}/../function-login/swagger-login.json xxx-api-basepath-xxx $LOGIN_API_BASEPATH
  
#   _out Deploying API: login
#   API_LOGIN=$(ibmcloud wsk api create --config-file ${root_folder}/../function-login/swagger-login.json | awk '/https:/{ print $1 }')
#   _out API_LOGIN: $API_LOGIN
#   printf "\nAPI_LOGIN=$API_LOGIN" >> $ENV_FILE

#   _out Updating function: ${FN_GENERIC_PACKAGE}/login
#   rm $CONFIG_FILE
#   touch $CONFIG_FILE
#   printf "{\n" >> $CONFIG_FILE
#   printf "\"client_id\": \"" >> $CONFIG_FILE
#   printf $APPID_CLIENTID >> $CONFIG_FILE
#   printf "\",\n" >> $CONFIG_FILE
#   printf "\"client_secret\": \"" >> $CONFIG_FILE
#   printf $APPID_SECRET >> $CONFIG_FILE
#   printf "\",\n" >> $CONFIG_FILE
#   printf "\"oauth_url\": \"" >> $CONFIG_FILE
#   printf $APPID_OAUTHURL >> $CONFIG_FILE
#   printf "\",\n" >> $CONFIG_FILE
#   printf "\"webapp_redirect\": \"" >> $CONFIG_FILE
#   printf "http://localhost:4200" >> $CONFIG_FILE
#   printf "\",\n" >> $CONFIG_FILE
#   printf "\"redirect_uri\": \"" >> $CONFIG_FILE
#   printf $API_LOGIN >> $CONFIG_FILE
#   printf "\"\n" >> $CONFIG_FILE
#   printf "}" >> $CONFIG_FILE
#   CONFIG=`cat $CONFIG_FILE`
#   ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/login ${root_folder}/../function-login/login.js --kind nodejs:10 -p config "${CONFIG}"

#   _out Creating redirect URL in App ID: $API_LOGIN
#   IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
#   curl -s -X PUT \
#     --header 'Content-Type: application/json' \
#     --header 'Accept: application/json' \
#     --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
#     -d '{"redirectUris": [
#             "'$API_LOGIN'", "http://ibm.biz/login-nh"
#           ]
#         }' \
#     "${APPID_MGMTURL}/config/redirect_uris"
# }
