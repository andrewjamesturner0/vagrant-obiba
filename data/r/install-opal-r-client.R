#! /usr/bin/Rscript --vanilla

# Install datashield client R packages
install.packages('datashieldclient', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)
install.packages('opaladmin', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)
