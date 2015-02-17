#!/bin/bash

VAGRANT_DATA=/vagrant_data

# copy test data to opal filesystem
sudo cp -r "${VAGRANT_DATA}/opal/testdata" "/var/lib/opal/fs/home/administrator/"
sudo chown -R opal:nogroup /var/lib/opal/fs
