# read in data
df <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv"),
               show_col_types = FALSE) %>%
  # rename RSV A/B to avoid problems when saving data
  mutate(typ = ifelse(typ == "RSV A/B", "RSV AB", typ))

# store column names
df_colnames <- names(df)

# helping dataframe to get periods for loess estimation
temp <- df %>%
  filter(!is.na(!!sym(viruslast_untersucht))) %>%
  group_by(standort, typ) %>%
  # compute differences between consecutive measurement days
  mutate(
    dif = as.numeric(datum - lag(datum)),
    # count how often there are 4 weeks (currently set in "functions_packages.R
    # for ww_meas_period) without measurements (as then a new
    # loess curve is estimated)
    four_weeks_nas = ifelse(dif > wo_meas_period &
                              !is.na(dif), 1, 0),
    loess_period = cumsum(four_weeks_nas)
  ) %>%
  ungroup() %>%
  # select relevant variables
  select(standort, typ, datum, loess_period)

df <- df %>%
  # first drop loess estimates and derived quantities (to show how to calculate them)
  select(-contains("loess")) %>%
  # merge with loess period data set created above
  left_join(temp) %>%
  group_by(standort, typ) %>%
  mutate(
    # add lab number per site (first lab gets 0, second lab gets 1 etc.)
    laborwechsel_numerisch = ifelse(laborwechsel == "ja", 1, 0),
    labor = cumsum(laborwechsel_numerisch),
  ) %>%
  # create log values
  mutate(log_viruslast = log10(!!sym(viruslast_untersucht))) %>%
  # drop variables not needed any more
  dplyr::select(-laborwechsel_numerisch) %>%
  # fill NAs
  arrange(standort, typ, datum) %>%
  group_by(standort, typ) %>%
  fill(c("loess_period", "labor"), .direction = "down") %>%
  ungroup() %>%
  # indicate whether minimum of observations is met in loess period, also consider that
  # laboratory changes also constitute a new time frame
  group_by(typ, standort, loess_period, labor) %>%
  mutate(n = sum(!is.na(!!sym(
    viruslast_untersucht
  ))),
  min_obs_exceeded = ifelse(n >= min_obs, 1, 0)) %>%
  ungroup()

# save data set with too few observations to calculate loess curve,
# this data set is combined with the remaining data further below again
df_small <- df %>%
  filter(min_obs_exceeded < 1)

# save data set with sufficient observations per site to calculate loess curves
df <- df %>%
  filter(min_obs_exceeded > 0) %>%
  arrange(standort, typ, datum)

# calculate loess estimates for each virus, site, loess_period, lab combination
# see help(loess.as) for details of the set options
# loess sometimes does not work well for small samples with many
# values below limit of quantification, in this case the span is set automatically
# to 0.75
pred <- df %>%
  group_by(standort, typ, loess_period, labor) %>%
  mutate(obs = row_number()) %>%
  nest() %>%
  mutate(pred = map(data, ~ tryCatch({
    predict(
      loess.as(
        .x$obs[!is.na(.x$log_viruslast)],
        .x$log_viruslast[!is.na(.x$log_viruslast)],
        criterion = "aicc",
        family = "gaussian",
        degree = 2,
        control = loess.control(surface = "direct")
      ),
      newdata = data.frame(x = .x$obs),
      se = TRUE
    )
  }, warning = function(w) {
    message(
      "Warning in group ",
      unique(standort),
      ", pathogen ",
      unique(typ),
      ": ",
      conditionMessage(w)
    )
    predict(
      loess.as(
        .x$obs[!is.na(.x$log_viruslast)],
        .x$log_viruslast[!is.na(.x$log_viruslast)],
        family = "gaussian",
        degree = 2,
        user.span = .75,
        control = loess.control(surface = "direct")
      ),
      newdata = data.frame(x = .x$obs),
      se = TRUE
    )
  })))

# extract and unnest relevant list
pred <- pred %>%
  select(pred) %>%
  unnest(cols = c(pred))

# store list
pred_list <- pred[, "pred"]$pred

# store number of observations per group
reps <- df %>%
  group_by(standort, typ, loess_period, labor) %>%
  summarise(n = n()) %>%
  pull(n)

df <- df %>%
  # add columns relevant for predictions
  add_column(
    loess_vorhersage = extract_prediction(lis = pred_list, extract = "fit"),
    loess_vorhersage_se = extract_prediction(lis = pred_list, extract = "se.fit"),
    loess_vorhersage_df = extract_prediction(lis = pred_list, "df") %>%
      map2(., reps, ~ rep(.x, .y)) %>%
      unlist()
  ) %>%
  group_by(standort, typ, loess_period, labor) %>%
  mutate(
    # compute minimum value
    min_log_viruslast = min(log_viruslast, na.rm = T),
    # check it af least one value below loq
    at_least_one_loq = sum(unter_bg == "ja", na.rm = TRUE) > 0,
    # if so, ensure that predictions are equal to at least the respective loq
    # for influenza virus types (as they are not normalized and have a clear
    # lower bound)
    loess_vorhersage  = ifelse(
      loess_vorhersage < min_log_viruslast  &
        at_least_one_loq &
        grepl("Influenza", typ),
      min_log_viruslast,
      loess_vorhersage
    )
  ) %>%
  ungroup() %>%
  # compute pointwise confidence bands
  mutate(
    loess_untere_schranke = loess_vorhersage - qt(0.975, loess_vorhersage_df) *
      loess_vorhersage_se,
    loess_obere_schranke = loess_vorhersage + qt(0.975, loess_vorhersage_df) *
      loess_vorhersage_se,
    # transform to original scale
    loess_untere_schranke = 10 ^ loess_untere_schranke,
    loess_obere_schranke = 10 ^ loess_obere_schranke,
    loess_vorhersage = 10 ^ (loess_vorhersage),!!sym(viruslast_untersucht) := 10 ^ (log_viruslast)
  ) %>%
  # drop variables
  select(-min_log_viruslast, -at_least_one_loq)

# arrange data
data_combined <-
  df  %>% filter(!is.na(loess_vorhersage)) %>%
  arrange(standort, datum)

# add data with few measurements
data_combined <- data_combined %>%
  bind_rows(df_small)

# clean up
rm(df, df_small, pred, pred_list, reps, temp)

# clean up data
data_combined <- data_combined %>%
  group_by(standort, typ) %>%
  mutate(
    # combine changes in data for plots
    loess_period = loess_period + labor,
    loess_period = factor(loess_period)) %>%
  ungroup() %>%
  select(
    standort,
    bundesland,
    datum,
    !!sym(viruslast_untersucht),
    loess_vorhersage,
    loess_obere_schranke,
    loess_untere_schranke,
    einwohner,
    laborwechsel,
    typ,
    unter_bg,
    loess_period,
    labor
  )
