#!/bin/bash

root_folder=$(
    cd $(dirname $0)
    pwd
)

readonly LOG_FILE="${root_folder}/deploy-finale-function.log"
readonly ENV_FILE="${root_folder}/../local.env"

touch $LOG_FILE
exec 3>&1 # Save stdout
exec 4>&2 # Save stderr
exec 1>$LOG_FILE 2>&1

source ${root_folder}/functions.sh
source $ENV_FILE

if [ ! -e "$ENV_FILE" ]; then
    _err "local.env does not exist.  Check logs for errors and start again."
    exit 1
fi
ibmcloud_login
API_HOME=$(ibmcloud fn api list | grep demo | awk '{print $4}')
if [ "x${API_HOME}" == "x" ]; then
    _err "No API_HOME variable set. Check the logs for errors."
else
    launch_browser_if_available ${API_HOME}
    _out "Done! Navigate to ${API_HOME}"
fi
