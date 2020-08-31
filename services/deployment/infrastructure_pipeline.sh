#!/bin/bash

./services/deployment/startup.sh
if [ $? -ne 0 ]; then
    echo "Startup unexpectedly failed.  Check log, take copy of logs and screenshots, and report."
    exit 1
fi
./services/infrastructure/delete-resources.sh
if [ $? -ne 0 ]; then
    echo "Failed to remove all resources, check logs and manually remove."
    exit 1
fi
./services/infrastructure/build.sh
if [ $? == 0 ]; then
    echo
    echo
    echo "******************************************************"
    echo "You will need to rebuild the other service layers now."
    echo "******************************************************"
else
    echo "Oops, something went wrong. Check the log and try building locally."
fi
