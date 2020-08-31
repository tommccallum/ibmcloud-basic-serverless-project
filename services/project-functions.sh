#!/bin/bash

pf_source_directory=$(dirname "$BASH_SOURCE")
source "${pf_source_directory}/project-constants.sh"

function check_basic_tools() {
  MISSING_TOOLS=""
  git --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} git"
  curl --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} curl"
  ibmcloud --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} ibmcloud"
  if [[ -n "$MISSING_TOOLS" ]]; then
    _err "Some tools (${MISSING_TOOLS# }) could not be found, please install them first and then run scripts/setup-app-id.sh"
    exit 1
  fi
}

function check_project_tools() {
  MISSING_TOOLS=""
  git --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} git"
  curl --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} curl"
  ibmcloud --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} ibmcloud"
  yarn --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} yarn"
  php --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} php"
  php --ini | grep zip &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} php-pecl-zip"
  composer --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} composer"
  laravel --version &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} laravel"
  python --version | grep "Python 3" &>/dev/null || MISSING_TOOLS="${MISSING_TOOLS} python3"
  if [[ -n "$MISSING_TOOLS" ]]; then
    _err "Some tools (${MISSING_TOOLS# }) could not be found, please install them first and then run scripts/setup-app-id.sh"
    exit 1
  fi
}

# Assumes we have sourced our local variables
function sanity_check_local_vars() {
  if [ "x${PROJECT_PREFIX}" == "x" ]; then
    _fatal "sanity_check_local_vars: No project prefix found"
  fi
  if [ "x${PROJECT_NAME}" == "x" ]; then
    _fatal "sanity_check_local_vars: No project name found"
  fi
  if [ "x${VERSION}" == "x" ]; then
    _fatal "sanity_check_local_vars: No version found"
  fi
  if [ "x${PROJECT_SHORT}" == "x" ]; then
    _fatal "sanity_check_local_vars: No project short name found"
  fi
}