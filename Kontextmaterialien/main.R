# setup ----

# clear environment
rm(list = ls())

# in case not installed, install pacman package by using the command
if (!"pacman" %in% rownames(installed.packages()))
  install.packages("pacman")

# should log data be shown in created graphics?
# set TRUE or FALSE
show_log_data = TRUE

# should flow-normalized data be used?
# set TRUE or FALSE
use_normalized_data = FALSE

# minimum of observations per treatment plant that are required to be analyzed
min_obs = 10

# minimum of number of treatment plants that are required to aggregate them
min_obs_agg = 20

# number of days without measurements that are needed to start a new estimation period,
# i.e. a new gam estimation is done after such a time frame without measurements
# default: 4 weeks
wo_meas_period = 28

# set virus that should be analyzed and whether weights should be applied when
# aggregating over sites
pathogens <- c(
  "SARS-CoV-2",
  "Influenza A",
  "Influenza B",
  "Influenza A+B",
  "RSV A",
  "RSV B",
  "RSV A+B",
  "RSV AB"
)
weight_pathogen <- rep(TRUE, length(pathogens))

# (install and) load here package
pacman::p_load(here)

# determine path(s) where scripts, data and results are located / stored
scripts_here <-
  here(here(), "Scripts")
read_data_here <-
  normalizePath(file.path(here(), ".."))
results_here <-
  here(here(), "Results")
var_names <- paste0(
  "results_here_",
  c(
    "sars",
    "influenza_a",
    "influenza_b",
    "influenza_gesamt",
    "rsv_a",
    "rsv_b",
    "rsv_gesamt",
    "rsv_ab"
  )
)
paths = paste(here(results_here, pathogens))

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

# define variable of interest as determined above (normalized or not)
if (use_normalized_data == TRUE)
  viruslast_untersucht <- "viruslast_normalisiert" else
  viruslast_untersucht <- "viruslast"

# (install and) load packages, read in functions, directories and self-defined values
source(here(scripts_here, "functions_packages.R"), encoding = "UTF-8")

# this script is for understanding how gam curves, confidence intervals
# and trends are calculated from single site data; no output is created
source(here(scripts_here, "loess_calculation.R"), encoding = "UTF-8")

# this script is for understanding how aggregation of data takes place and how
# gam curves and trends are calculated for aggregated data, i.e. it is also shown
# how the aggregated data set is derived from single site data; no output is created
source(here(scripts_here, "aggregation_calculation.R"), encoding = "UTF-8")

# plot single sites and save their data
source(here(scripts_here, "plot_single_places.R"), encoding = "UTF-8")

# plot aggregated curve
source(here(scripts_here, "plot_aggregated_curve.R"), encoding = "UTF-8")

# plot loq plots
source(here(scripts_here, "plot_loq_plot.R"), encoding = "UTF-8")
