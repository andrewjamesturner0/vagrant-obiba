#!/bin/bash

VAGRANT_DATA='/root/vagrant-obiba/data'

source $VAGRANT_DATA/settings

if [ $(grep -c '^deb http://www.stats.bris.ac.uk/R/bin/linux/ubuntu precise/' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
	sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" >> /etc/apt/sources.list'
fi

if [ $(grep -c '^deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' /etc/apt/sources.list) -eq 0 ];
then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
fi

sudo apt-get update

# MongoDB install
sudo apt-get install mongodb-10gen

# MySQL install
if [ ! -d /etc/mysql ];
then
  echo mysql-server mysql-server/root_password select $MYSQL_ROOT_PWD | debconf-set-selections
  echo mysql-server mysql-server/root_password_again select $MYSQL_ROOT_PWD | debconf-set-selections
	sudo apt-get -y install mysql-server
fi
sudo cp $VAGRANT_DATA/mysql/my.cnf /etc/mysql
sudo service mysql restart

# Java7 install
sudo apt-get -y install java7-runtime
sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java

# execute this after Java installation so we are sure MySQL is running
echo "CREATE DATABASE opal_data CHARACTER SET utf8 COLLATE utf8_bin" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "CREATE DATABASE opal_ids CHARACTER SET utf8 COLLATE utf8_bin" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "CREATE USER '$MYSQL_OPAL_USER'@'localhost' IDENTIFIED BY '$MYSQL_OPAL_PWD'" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "GRANT ALL ON opal_data.* TO '$MYSQL_OPAL_USER'@'localhost'" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "GRANT ALL ON opal_ids.* TO '$MYSQL_OPAL_USER'@'localhost'" | mysql -uroot -p$MYSQL_ROOT_PWD
echo "FLUSH PRIVILEGES" | mysql -uroot -p$MYSQL_ROOT_PWD

# Opal install
echo opal opal-server/admin_password select $OPAL_PWD | debconf-set-selections
echo opal opal-server/admin_password_again select $OPAL_PWD | debconf-set-selections
sudo apt-get install -y opal
sudo apt-get install -y opal-python-client

# R dependencies
sudo apt-get install -y opal-rserver
sudo service rserver restart

# Opal Datashield
#sudo Rscript $VAGRANT_DATA/r/install-opal-r-client.R
#sudo Rscript $VAGRANT_DATA/r/install-opal-r-server.R

# R studio
#sudo apt-get -y install libapparmor1
#sudo apt-get -y install gdebi-core
#wget -q http://download2.rstudio.org/$RSTUDIO
#sudo gdebi -n $RSTUDIO
#rm $RSTUDIO
#sudo cp /usr/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d
#sudo update-rc.d rstudio-server defaults

# Add default datashield user
#sudo adduser --disabled-password --gecos "" datashield
#echo "datashield:datashield4ever" | sudo chpasswd

# Add databases in Opal at the end of the VM setup so we are sure that Opal is running
echo "Create Opal databases"
opal rest -o http://localhost:8080 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/idsdb.json
opal rest -o http://localhost:8080 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/sqldb.json
opal rest -o http://localhost:8080 -u administrator -p $OPAL_PWD -m POST /system/databases --content-type "application/json" < $VAGRANT_DATA/opal/mongodb.json
