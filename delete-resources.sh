#!/bin/bash

source local.env

ibmcloud resource service-alias-delete ${APP_ID} -f

ibmcloud resource service-key-delete ${CLOUDANT}-credentials -f
ibmcloud resource service-key-delete ${APP_ID}-credentials -f
ibmcloud resource service-key-delete ${OBJECT_STORAGE}-credentials -f

ibmcloud resource service-instance-delete ${CLOUDANT} -f
ibmcloud resource service-instance-delete ${APP_ID} -f
ibmcloud resource service-instance-delete ${OBJECT_STORAGE} -f
ibmcloud fn namespace delete ${FN_NAMESPACE} 

ibmcloud iam api-key-delete ${PROJECT_NAME} -f
