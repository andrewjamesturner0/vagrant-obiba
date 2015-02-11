#! /usr/bin/Rscript --vanilla

# Install datashield server R packages via opal
library(opaladmin)
o<-opal.login('administrator', 'password', url='https://localhost:8443')
dsadmin.install_package(o, 'datashield')
dsadmin.set_package_methods(o, pkg='dsBase')
dsadmin.set_package_methods(o, pkg='dsStats')
dsadmin.set_package_methods(o, pkg='dsGraphics')
dsadmin.set_package_methods(o, pkg='dsModelling')
opal.logout(o)
