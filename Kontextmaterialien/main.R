# setup ----
# in case not installed, install pacman package by using the command
# install.packages("pacman", repos="https://cran.rstudio.com/")
# clean up environment
rm(list = ls())

# should log data be shown in created graphics?
# set TRUE or FALSE
show_log_data = TRUE

# (install and) load here package
pacman::p_load(here)

# determine path(s) where scripts, data and results are located / stored
scripts_here <-
  here(here(), "Scripts")
read_data_here <-
  here("..")
results_here <-
  here(here(), "Results")
results_single_places_here <-
  here(here(), "Results/Single_Sites")

# check if results directory exists
if (!dir.exists(here(results_here)))
{
  # otherwise create it
  dir.create(here(results_here))
}
# check if single-places results directory exists
if (!dir.exists(here(results_single_places_here)))
{
  # otherwise create it
  dir.create(here(results_single_places_here))
}

# (install and) load packages, read in functions, directories and self-defined values
source(here(scripts_here, "functions_packages.R"),
       encoding = "UTF-8")

# this script is for understanding how loess curve, confidence intervals
# and trends are calculated from single site data; no output is created
source(here(scripts_here, "loess_calculation.R"), encoding = "UTF-8")

# this script is for understanding how aggregation of data takes place and how 
# loess curve and trends are calculated for aggregated data, i.e. it is also shown
# how the aggregated data set is derived from single site data; no output is created
source(here(scripts_here, "aggregation_calculation.R"), encoding = "UTF-8")

# plot single sites and save their data
source(here(scripts_here, "plot_single_places.R"), encoding = "UTF-8")

# plot aggregated curve
source(here(scripts_here, "plot_aggregated_curve.R"), encoding = "UTF-8")

# plot heatmap
source(here(scripts_here, "plot_heatmap.R"), encoding = "UTF-8")
