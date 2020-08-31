#/bin/bash

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start
root_folder=$(get_root_folder)


_out Updating function: ${FN_GENERIC_PACKAGE}/redirect

API_TO_REDIRECT_TO="public"
ALL_ENDPOINTS=( $(grep "${API_TO_REDIRECT_TO}_API_URL" ${ENV_FILE}) )
if [ ${#ALL_ENDPOINTS[@]} -eq 0 ]
then
    _fatal "No ${API_TO_REDIRECT_TO} urls found to register as redirects."
fi

URLS=()
for api_url_var in ${ALL_ENDPOINTS[@]}
do
    api_url=$(awk -F '=' '{print $2}' <<< ${api_url_var} | sed 's/\"//g' )
    if [ "x$api_url" == "x" ]; then
        _fatal "Empty value in '${api_url_var}'"
    fi
    _out "Registering '$api_url'"
    URLS+=($api_url)
done

JSON_ARRAY=""
for url in ${URLS[@]}
do
    if [ "x$JSON_ARRAY" == "x" ]; then
        JSON_ARRAY="\"$url\""
    else
        JSON_ARRAY="${JSON_ARRAY},\"$url\""
    fi
done
JSON_ARRAY="[${JSON_ARRAY}]"

echo "Writing JSON array for debugging"
echo "${JSON_ARRAY}"

ibmcloud_project_login ${PROJECT_NAME}

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

readonly LOGIN_DIR="${root_folder}/../../function-login"
readonly CONFIG_FILE="${LOGIN_DIR}/config.json"
[[ -e "${CONFIG_FILE}" ]] && rm $CONFIG_FILE
touch $CONFIG_FILE

WEBAPP_REDIRECT=${angularwebapp_public_API_URL}

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
printf ${WEBAPP_REDIRECT} >> $CONFIG_FILE
printf "\",\n" >> $CONFIG_FILE
printf "\"redirect_uri\": \"" >> $CONFIG_FILE
printf $API_LOGIN >> $CONFIG_FILE
printf "\"\n" >> $CONFIG_FILE
printf "}" >> $CONFIG_FILE
CONFIG=`cat $CONFIG_FILE`

ibmcloud wsk action update ${FN_GENERIC_PACKAGE}/redirect ${LOGIN_DIR}/redirect.js --kind ${NODE_VERSION} -a web-export true -p config "${CONFIG}"
if [ $? -ne 0 ]; then
    _fatal "Could not update redirect action with url, check log for error."
else
    _ok "Successfully updated redirect action"
fi

# need to update App Id redirects
APPID_MGMTURL=$(app_id_get_management_url ${APP_ID_NAME})
if [ "x$APPID_MGMTURL" == "x" ]; then
    _fatal "No App ID Management URL found, check that App ID script ran without error."
fi

if [ "x${API_LOGIN}" == "x" ]; then
    _fatal "Login api was empty, check that setup-login-api ran properly."
fi

#IBMCLOUD_BEARER_TOKEN=$(get_oauth_token)
IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
if [ "x${IBMCLOUD_BEARER_TOKEN}" == "x" ]; then
    _fatal "OAuth token was empty."
fi
_out "Creating redirect URL in App ID: '$API_LOGIN'"
curl -s -X PUT \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"redirectUris": [
            "'$API_LOGIN'"
        ]}' \
    "${APPID_MGMTURL}/config/redirect_uris"
if [ $? -ne 0 ]; then
    _fatal "Failed to update redirect urls in App Id"
else
    _ok "Redirect urls in App ID were updated successfully"
fi
