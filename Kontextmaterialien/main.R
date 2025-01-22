# setup ----

# clear environment
rm(list = ls())

# in case not installed, install pacman package by using the command
if (!"pacman" %in% rownames(installed.packages()))
  install.packages("pacman")

# set virus that should be analyzed and whether weights should be applied when
# aggregating over sites
pathogens <- c("SARS-CoV-2", "Influenza A", "Influenza B", "Influenza A+B")
weight_pathogen <- c("TRUE", "FALSE", "FALSE", "FALSE")

# should log data be shown in created graphics?
# set TRUE or FALSE
show_log_data = TRUE

# set number of observations per date that have to be there to allow aggregation
min_obs = 10

# number of days without measurements that are needed to start a new loess period,
# i.e. a new loess estimation is done after such a time frame without measurements
# default: 4 weeks
wo_meas_period = 28

# (install and) load here package
pacman::p_load(here)

# determine path(s) where scripts, data and results are located / stored
scripts_here <-
  here(here(), "Scripts")
read_data_here <-
  normalizePath(file.path(here(), ".."))
results_here <-
  here(here(), "Results")
var_names <- paste0("results_here_",
                    c("sars", "influenza_a", "influenza_b", "influenza_gesamt"))
paths = paste(here(
  results_here,
  pathogens
))

# check if results directory exists
if (!dir.exists(here(results_here)))
{
  # otherwise create it
  dir.create(here(results_here))
}

# Assign variables in one shot using a loop, also create directories if necessary
for (i in seq_along(var_names)) {
  assign(var_names[i], paths[i], envir = .GlobalEnv)
  if (!dir.exists(paths[i]))
    dir.create(paths[i])
  if (!dir.exists(here(paths[i], "Single_Sites")))
    dir.create(here(paths[i], "Single_Sites"))
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

# plot loq plots
source(here(scripts_here, "plot_loq_plot.R"), encoding = "UTF-8")
