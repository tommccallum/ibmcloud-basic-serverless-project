#!/bin/bash

# ENV_FILE (local.env) may not exist when this is called.
# For example if we are in a build pipeline, but the resources may still exist.
# Just in case we will look for the top level key and if that exists then
# we will copy over the ENV_FILE read it in and continue from there.
root_folder=$(
    cd $(dirname $0)
    pwd
)
EXPECTED_VARS="$root_folder/../../local.env"
HAS_PIPELINE_IN_CURRENT_PATH=$(echo "${root_folder}" | grep "/home/pipeline/")
if [ ! -e "${EXPECTED_VARS}" -a "x$HOME" == "x/root" -a "x$HAS_PIPELINE_IN_CURRENT_PATH" != "x" ]; then
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
    EXISTING_RESOURCE=$(ibmcloud resource service_instances | grep "${PROJECT_PREFIX}" | awk '{print $1}' | awk -F '-' '{ print $1"-"$2 }')
    if [ "x$EXISTING_RESOURCE" == "x" ]; then
        echo "No resource found with name '${PROJECT_PREFIX}', assuming no resources exist currently for this project."
        TEMPLATE="$root_folder/../../local.env.template"
        if [ ! -e "$TEMPLATE" ]; then
            echo "Failed to find local.env template"
            exit 1
        else
            echo "Copying template to create new '${EXPECTED_VARS}'"
            cp "$TEMPLATE" "$EXPECTED_VARS"
            source $EXPECTED_VARS
            echo "VERSION: $VERSION"
            echo "PROJECT_PREFIX: $PROJECT_PREFIX"
            echo "PROJECT_NAME: $PROJECT_NAME"
        fi
        exit 0
    else
        TEMPLATE="$root_folder/../../local.env.template"
        if [ ! -e "$TEMPLATE" ]; then
            echo "Failed to find local.env template"
            exit 1
        else
            cp "$TEMPLATE" "$EXPECTED_VARS"
            EXP_PROJECT_PREFIX=$(awk -F '-' '{ print $1 }' <<<$EXISTING_RESOURCE)
            EXP_VERSION=$(awk -F '-' '{ print $2 }' <<<$EXISTING_RESOURCE)
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
else
    echo "Detected we are not in a pipeline or docker instance"
fi
