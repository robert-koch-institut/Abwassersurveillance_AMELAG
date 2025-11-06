## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(renv)

## ----eval = FALSE-------------------------------------------------------------
# # restore packages from the lockfile, bypassing the cache
# renv::restore(rebuild = TRUE)
# 
# # re-install a package
# renv::install("<package>", rebuild = TRUE)
# 
# # rebuild all packages in the project
# renv::rebuild()

## ----eval = FALSE-------------------------------------------------------------
# # installation of RNetCDF may require us to set include paths for netcdf
# configure.args = c(RNetCDF = "--with-netcdf-include=/usr/include/udunits2")
# options(configure.args = configure.args)
# renv::install("RNetCDF")

## ----eval = FALSE-------------------------------------------------------------
# options(
#   configure.args.RNetCDF = "--with-netcdf-include=/usr/include/udunits2"
# )
# renv::install("RNetCDF")

## ----eval = FALSE-------------------------------------------------------------
# # installation of R packages using the Windows Subsystem for Linux
# # may require the `--no-lock` flag to be set during install
# options(install.opts = "--no-lock")
# renv::install("xml2")
# 
# # alternatively, you can set such options for specific packages with e.g.
# options(install.opts = list(xml2 = "--no-lock"))
# renv::install("xml2")

## ----eval=FALSE---------------------------------------------------------------
# getOption("download.file.method")

## ----eval=FALSE---------------------------------------------------------------
# renv:::renv_download_method()

## ----eval=FALSE---------------------------------------------------------------
# Sys.setenv(RENV_DOWNLOAD_METHOD = getOption("download.file.method"))

