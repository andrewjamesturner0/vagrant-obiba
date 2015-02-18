#!/bin/bash

VAGRANT_DATA=/vagrant_data
PROJECT_DIR=/opal/projects
PROJECTS=(CNSIM GEE SurvivalAnalysis)

for i in ${PROJECTS[@]}; do

    opal rest \
        -o https://localhost:8443 \
        -u administrator -p password \
        -m POST /projects \
        --content-type "application/json" \
        < "${VAGRANT_DATA}${PROJECT_DIR}/${i}.json"

done
