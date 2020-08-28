#!/bin/bash

RESTORE=0
./venv_active.py
if [ $? -ne 0 ]
then
 echo "Activating virtual environment"
 . venv/bin/activate
 RESTORE=1
fi

# enable development features
export FLASK_DEV=development

# set this to the starting file of your flask application
export FLASK_APP=main.py

# start the Flask web server
flask run

if [ $RESTORE -gt 0 ]
then
 echo "Deactivating virtual environment"
 deactivate
fi

