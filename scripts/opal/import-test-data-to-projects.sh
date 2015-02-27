#!/bin/bash


VAGRANT_DATA=/vagrant_data
PROJECT_DIR=/opal/projects
PROJECTS=(CNSIM GEE SurvivalAnalysis)

opal import-xml \
        -o https://localhost:8443 \
        -u administrator -p password \
        --destination CNSIM \
        --path /home/administrator/CNSIM-testdata/CNSIM1.zip

