#!/bin/bash

source ibm_std_functions.sh
standard_project_script_start

WORKLOAD="$1"

run scripts/infrastructure/build.sh
run scripts/data/build.sh
run scripts/platform-independent/build.sh
run scripts/framework/build.sh
run scripts/platform-dependent/build.sh


