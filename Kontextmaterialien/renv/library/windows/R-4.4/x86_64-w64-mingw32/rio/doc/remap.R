## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----map1---------------------------------------------------------------------
library(rio)
export(list("mtcars" = mtcars, "iris" = iris), "example.xlsx")
import("example.xlsx", which = "mtcars")

## ----map2---------------------------------------------------------------------
import("example.xlsx", sheet = "mtcars")

## ----map3---------------------------------------------------------------------
## n_max is an argument of readxl::read_xlsx
import("example.xlsx", sheet = "iris", n_max = 10)

## ----map4---------------------------------------------------------------------
import("example.xlsx", sheet = "iris", n_max = 10, pizza = "pineapple")

## ----echo = FALSE, results = 'hide'-------------------------------------------
unlink("example.xlsx")

