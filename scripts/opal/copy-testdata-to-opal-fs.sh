#!/bin/bash

VAGRANT_DATA=/vagrant_data

# copy test data to opal filesystem
cp -r "${VAGRANT_DATA}/opal/testdata" "/var/lib/opal/fs/home/administrator/"
