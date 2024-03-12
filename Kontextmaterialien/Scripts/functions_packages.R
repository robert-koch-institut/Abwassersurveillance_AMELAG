# set number of observations per date that have to be there to allow aggregation
min_obs = 10

# install (if not done yet) and load requireed packages
pacman::p_load(here,
               rio,
               tidyverse,
               reshape,
               padr,
               fANCOVA,
               writexl)

# define function that computes variance of a weighted mean
var_weighted <- function(x = NULL, wt = NULL) {
  xm = weighted.mean(x, wt)
  return(sum(wt * (x - xm) ^ 2) / (sum(wt) - 1) / sum(wt))
}

# function for substituting german umlaute
replace_umlauts <- function(text) {
  # Replace umlauts with their ASCII counterparts
  text <- gsub("ä", "ae", text)
  text <- gsub("ö", "oe", text)
  text <- gsub("ü", "ue", text)
  text <- gsub("Ä", "Ae", text)
  text <- gsub("Ö", "Oe", text)
  text <- gsub("Ü", "Ue", text)
  text <- gsub("ß", "ss", text)
  return(text)
}

# population in Germany at end of June 2023
# https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Bevoelkerungsstand/_inhalt.html, accessed on 25/10/2023
pop <- 84482000
