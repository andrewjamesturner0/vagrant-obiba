#!/bin/bash

VAGRANT_DATA=/vagrant_data

source $VAGRANT_DATA/settings

cd /tmp

# download lastest distribution from jenkins

# output: >mica_distribution-7.x-9.0-b3083.tar.gz
MICA_UNSTABLE_ARCHIVE=`wget -q -O - http://ci.obiba.org/view/Mica/job/Mica/ws/target/ | grep -o ">mica[^\'\"]*.tar.gz"`

# remove first character
MICA_UNSTABLE_ARCHIVE=${MICA_UNSTABLE_ARCHIVE:1}

# remove .tar.gz
MICA_UNSTABLE=${MICA_UNSTABLE_ARCHIVE/\.tar\.gz/}
echo ">> Prepare $MICA_UNSTABLE setup"

RELEASE_URL=http://ci.obiba.org/view/Mica/job/Mica/ws/target/$MICA_UNSTABLE_ARCHIVE
echo ">> Download $RELEASE_URL"

sudo wget -q $RELEASE_URL
sudo tar xzf $MICA_UNSTABLE_ARCHIVE
sudo cp -r $MICA_UNSTABLE /var/www/mica
sudo chown -R www-data:www-data /var/www/mica

# load preinstalled database
echo ">> Import Mica database"
mysql -u $MYSQL_MICA_USER --password=$MYSQL_MICA_PWD mica < $VAGRANT_DATA/mica/mica-dev.sql

# copy mica settings.php
echo ">> Configure Mica settings.php"
sudo cp $VAGRANT_DATA/mica/settings.php /var/www/mica/sites/default/
sudo sed -i 's/@MYSQL_MICA_USER@/'$MYSQL_MICA_USER'/' /var/www/mica/sites/default/settings.php
sudo sed -i 's/@MYSQL_MICA_PWD@/'$MYSQL_MICA_PWD'/' /var/www/mica/sites/default/settings.php

# utilities
echo ">> Install utilities"
sudo apt-get -y install make unzip daemon

# Java7 install
echo ">> Install Java"
sudo apt-get -y install java7-runtime
sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java

# SolR setup
echo ">> Install SolR"
sudo mkdir -p /usr/share/mica-solr
sudo mkdir -p /etc/mica-solr
sudo mkdir -p /var/lib/mica-solr

# get source code
wget -q https://github.com/obiba/mica/archive/master.zip
unzip master.zip
cd /tmp/mica-master/src/main/deb/mica-solr/var/lib/mica-solr-installer
sudo make mica-solr-install-prepare
sudo make solr-install-setup
sudo cp /tmp/$MICA_UNSTABLE/profiles/mica_distribution/modules/search_api_solr/solr-conf/4.x/* /usr/share/mica-solr/solr/collection1/conf/
sudo make solr-install-finish
sudo cp /tmp/mica-master/src/main/deb/mica-solr/debian/init.d /etc/init.d/mica-solr
sudo chmod +x /etc/init.d/mica-solr
sudo update-rc.d mica-solr defaults
sudo service mica-solr start

# Clean temp files
rm -rf /tmp/$MICA_UNSTABLE