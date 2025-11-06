## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(renv)

## ----eval = FALSE-------------------------------------------------------------
# # use the latest-available Bioconductor release
# renv::init(bioconductor = TRUE)
# 
# # use a specific version of Bioconductor
# renv::init(bioconductor = "3.14")

## ----eval = FALSE-------------------------------------------------------------
# renv::settings$bioconductor.version("3.14")

## ----eval = FALSE-------------------------------------------------------------
# options(renv.bioconductor.repos = c(...))

## ----eval=FALSE---------------------------------------------------------------
# renv:::renv_paths_cellar()

