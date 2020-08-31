
#!/bin/bash

source ibm_std_functions.sh
source ../project-functions.sh
standard_project_script_start
root_folder=$(get_root_folder)

API_NAME="private"
API_DIR_NAME="api-${API_NAME}"
API_DIR="${root_folder}/../../${API_DIR_NAME}"
if [ ! -e "${API_DIR}" ]; then
    _fatal "Could not find directory ${API_DIR}"
fi
if [ "x${HIDDEN_API_BASEPATH}" == "x" ]; then
    _fatal "Variable HIDDEN_API_BASEPATH is not set in local environment"
fi

readonly PATHS_REAL_PATH="${API_DIR}/swagger-paths.json"
readonly CASES_REAL_PATH="${API_DIR}/swagger-case.json"
if [ ! -e "${PATHS_REAL_PATH}" ]; then 
    _fatal "${PATHS_REAL_PATH} is missing"
fi
if [ ! -e "${CASES_REAL_PATH}" ]; then 
    _fatal "${CASES_REAL_PATH} is missing"
fi

_out Creating swagger-protected.json
SWAGGER_TEMPLATE_PATH="${API_DIR}/swagger-template.json"
SWAGGER_REAL_PATH="${API_DIR}/swagger-${API_NAME}.json"
[[ -e "${SWAGGER_REAL_PATH}" ]] && rm ${SWAGGER_REAL_PATH}
cp ${SWAGGER_TEMPLATE_PATH} ${SWAGGER_REAL_PATH}
  
_out Deploying API: ${API_NAME}

# for the last one we need to remove final ',' character
# because sed is greedy in its matching we can do a simple replacement
remove_last_comma.py ${CASES_REAL_PATH} 
remove_last_comma.py ${PATHS_REAL_PATH} 

ibmcloud_project_login ${PROJECT_NAME}
set_default_function_namespace ${FN_NAMESPACE}

APPID_TENANTID=$(app_id_get_tenant_id ${APP_ID_NAME})
if [ "x${APPID_TENANTID}" == "x" ]; then 
    _fatal "App Id Tenant Id is empty."
fi

cp ${SWAGGER_TEMPLATE_PATH} ${SWAGGER_REAL_PATH}
SWAGGER_CONF="${SWAGGER_REAL_PATH}"
sed -i "s/xxx-api-name-xxx/${API_NAME}/" ${SWAGGER_CONF}
sed -i "s/xxx-api-basepath-xxx/${HIDDEN_API_BASEPATH}/" ${SWAGGER_CONF}
sed -i "s/xxx-tenantid-xxx/${APPID_TENANTID}/" ${SWAGGER_CONF}
sed -i -e "/xxx-paths-xxx/ { r ${PATHS_REAL_PATH}" -e "d;}" ${SWAGGER_CONF}
sed -i -e "/xxx-operations-xxx/ { r ${CASES_REAL_PATH}" -e "d;}" ${SWAGGER_CONF}


ibmcloud wsk api create --config-file ${SWAGGER_REAL_PATH}
if [ $? -ne 0 ]; then
    _fatal "Could not create ${API_NAME} API from ${SWAGGER_REAL_PATH}"
else 
    _ok "${API_NAME} API was created successfully"
fi





