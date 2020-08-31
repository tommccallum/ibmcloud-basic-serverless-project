#!/bin/bash

source ibm_std_functions.sh
root_folder=$(get_root_folder)
source ${root_folder}/../project-functions.sh
standard_project_script_start
root_folder=$(get_root_folder)

FRAMEWORK="angularwebapp"
FRAMEWORK_DIR="${root_folder}/../../${FRAMEWORKS_ROOT_DIR}/${FRAMEWORK}"
if [ ! -e "${FRAMEWORK_DIR}" ]; then
  _fatal "Missing directory: ${FRAMEWORK_DIR}"
fi

ibmcloud_project_login ${PROJECT_NAME}
set_default_function_namespace ${FN_NAMESPACE}
if [ $? -ne 0 ]; then
    _err "Failed to set default namespace ${FN_NAMESPACE}"
    ibmcloud fn namespace list
    _fatal
fi

API_LOGIN=$( ibmcloud fn api list | awk '/login\/login/ { print $4}' )
if [ "x$API_LOGIN" == "x" ]; then
  _fatal "Login API url could not be found, ensure you have run the platform-independent build and there were no errors."
fi
_out API_LOGIN: ${API_LOGIN}

# Get the root url for all the private API calls
API_PRIVATE_ROOT_URL=$( ibmcloud fn api list | awk '/private/ { print $4}' | head -n 1 | sed "s#\(.*private\)/.*#\1#" )
if [ "x$API_PRIVATE_ROOT_URL" == "x" ]; then
  _fatal "Private API url missing from environment, ensure you have run the platform-independent build and there were no errors."
fi
_out API_PRIVATE_ROOT_URL: ${API_PRIVATE_ROOT_URL}

APPID_OAUTHURL=$(app_id_get_oauth_server_url ${APP_ID_NAME})
if [ "x$APPID_OAUTHURL" == "x" ]; then
  _fatal "App ID Oauth URL missing."
fi

APPID_CLIENTID=$(app_id_get_client_id ${APP_ID_NAME})
if [ "x$APPID_CLIENTID" == "x" ]; then
  _fatal "App ID Client id missing."
fi


readonly TEMPLATE_CONFIG_FILE="${FRAMEWORK_DIR}/src/assets/template.config.json"
if [ ! -e "$TEMPLATE_CONFIG_FILE" ]; then
  _fatal "Missing template file: $TEMPLATE_CONFIG_FILE"
fi
readonly CONFIG_FILE="${FRAMEWORK_DIR}/src/assets/config.json"
[[ -e "${CONFIG_FILE}" ]] && rm "${CONFIG_FILE}"
cp ${TEMPLATE_CONFIG_FILE} ${CONFIG_FILE}
sed -i "s#xxx-authorizationUrl-xxx#${APPID_OAUTHURL}#" ${CONFIG_FILE}
sed -i "s#xxx-redirectUrl-xxx#${API_LOGIN}#" ${CONFIG_FILE}
sed -i "s#xxx-clientId-xxx#${APPID_CLIENTID}#" ${CONFIG_FILE}
sed -i "s#xxx-protectedUrl-xxx#${API_PRIVATE_ROOT_URL}#" ${CONFIG_FILE}

_out Downloading npm modules
npm --prefix ${FRAMEWORK_DIR} install ${FRAMEWORK_DIR}
if [ $? -ne 0 ]; then
  _fatal "Error running npm in $(abbreviate_file_path ${FRAMEWORKDIR})"
else 
  _ok "npm build was successful"
fi

_out To start the web application locally you can run ng serve in ${FRAMEWORK_DIR}
