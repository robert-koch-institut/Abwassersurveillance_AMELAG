## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- echo = FALSE, out.width = "400px"---------------------------------------
knitr::include_graphics("invalid_request.png")

## ----eval = FALSE-------------------------------------------------------------
#  library(googledrive)
#  
#  drive_auth(use_oob = TRUE)
#  
#  # now carry on with your work
#  drive_find(n_max = 5)

## ----eval = FALSE-------------------------------------------------------------
#  options(gargle_oob_default = TRUE)

## ----eval = FALSE-------------------------------------------------------------
#  options(gargle_oauth_client_type = "web")

