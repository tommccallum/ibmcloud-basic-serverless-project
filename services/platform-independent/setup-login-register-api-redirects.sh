#!/bin/bash


source ibm_std_functions.sh
source ../project-functions.sh
standard_project_script_start
ibmcloud_project_login ${PROJECT_NAME}

APPID_MGMTURL=$(app_id_get_management_url ${APP_ID_NAME})
if [ "x$APPID_MGMTURL" == "x" ]; then
    _fatal "No App ID Management URL found, check that App ID script ran without error."
fi

if [ "x${API_LOGIN}" == "x" ]; then
    _fatal "Login api was empty, check that setup-login-api ran properly."
fi

IBMCLOUD_BEARER_TOKEN=$(get_oauth_token)
if [ "x${IBMCLOUD_BEARER_TOKEN}" == "x" ]; then
    _fatal "OAuth token was empty."
fi
_out Creating redirect URL in App ID: $API_LOGIN
curl -s -X PUT \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"redirectUris": [
            "'$API_LOGIN'"
            ]
        }' \
    "${APPID_MGMTURL}/config/redirect_uris"