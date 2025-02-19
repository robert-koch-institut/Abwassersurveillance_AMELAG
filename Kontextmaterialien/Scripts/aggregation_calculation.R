# read in data
df <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv"),
               show_col_types = FALSE) %>%
  # rename RSV A/B to avoid problems when saving data
  mutate(typ = ifelse(typ == "RSV A/B", "RSV AB", typ))

# generate weeks starting on Thursday
thursday_data <-
  df %>%
  distinct(datum) %>%
  mutate(
    Tag = lubridate::wday(datum, week_start = 1),
    is_thursday = ifelse(Tag == 4, 1, 0),
    th_week = cumsum(is_thursday)
  ) %>%
  dplyr::select(datum, th_week, Tag)

# create aggregated data (aggregated over all sites)
df_agg <- df %>%
  left_join(thursday_data) %>%
  group_by(standort, typ) %>%
  # complete data
  fill(normalisierung, .direction = "updown") %>%
  mutate(unter_bg = ifelse(is.na(viruslast), "nein", unter_bg)) %>%
  ungroup() %>%
  # create log values
  mutate(log_viruslast = log10(viruslast)) %>%
  # add dates with NAs before measurements to avoid that 7-days-averages
  # drop values if no previous dates are available
  group_by(standort, typ) %>%
  pad(by = "datum",
      interval = "day",
      start_val = min(df$datum) - 7) %>%
  ungroup() %>%
  # for each site, compute 7-day averages
  group_by(standort, typ, th_week) %>%
  mutate_at(vars(contains("viruslast")), ~ mean(., na.rm = TRUE)) %>%
  # take only one value per week, site
  filter(datum == max(datum, na.rm = TRUE)) %>%
  ungroup() %>%
  # remove sites without available weight
  filter(!is.na(einwohner), !is.na(log_viruslast))

# Create an empty list as placeholder
agg_list <- list()

# set seed for reproducibility
set.seed(22)

# compute (un-)weighted means over all sites for each pathogen
for (i in 1:length(pathogens))
{
  agg_list[[i]] <-
    aggregation(df = df_agg,
                virus = pathogens[i],
                weighting = weight_pathogen[i])
  
}

# combine data sets
df_agg <- map_dfr(agg_list, bind_rows) %>%
  # important
  arrange(typ, datum) %>%
  group_by(datum) %>%
  # ensure that influenza and rsv gesamt is sum of the single viruses
  mutate(
    log_viruslast = ifelse(typ == "Influenza A+B", log10(sum(
      10 ^ log_viruslast[typ %in% c("Influenza A", "Influenza B")], na.rm = TRUE
    )), log_viruslast),
    log_viruslast = ifelse(typ == "RSV A+B", log10(sum(
      10 ^ log_viruslast[typ %in% c("RSV A", "RSV B")], na.rm = TRUE
    )), log_viruslast),
    # drop created zeros (if only NAs are summed up, a zero is created)
    log_viruslast = ifelse(log_viruslast < 0.0000001, NA, log_viruslast)
  ) %>%
  ungroup()

# compute loess predictions
pred <- df_agg %>%
  group_by(typ) %>%
  nest() %>%
  mutate(pred = map(data, ~ tryCatch({
    predict(
      loess.as(
        .x$obs[!is.na(.x$log_viruslast)],
        .x$log_viruslast[!is.na(.x$log_viruslast)],
        criterion = "aicc",
        family = "gaussian",
        degree = 2,
        weights = sqrt(.x$weights[!is.na(.x$log_viruslast)]),
        control = loess.control(surface = "direct")
      ),
      newdata = data.frame(x = .x$obs),
      se = TRUE
    )
  }, warning = function(w) {
    message("Warning in pathogen ", unique(typ), ": ", conditionMessage(w))
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
  }))) %>%
  select(pred) %>%
  unnest(cols = c(pred))

# store list
pred_list <- pred[, "pred"]$pred

# store number of observations per group
reps <- df_agg %>%
  group_by(typ) %>%
  summarise(n = n()) %>%
  pull(n)

df_agg <- df_agg %>%
  # add columns relevant for predictions
  add_column(
    loess_vorhersage = extract_prediction(lis = pred_list, extract = "fit"),
    loess_vorhersage_se = extract_prediction(lis = pred_list, extract = "se.fit"),
    loess_vorhersage_df = extract_prediction(pred_list, "df") %>%
      map2(., reps, ~ rep(.x, .y)) %>%
      unlist()
  ) %>%
  # compute pointwise confidence bands
  mutate(
    loess_untere_schranke = loess_vorhersage - qt(0.975, loess_vorhersage_df) *
      loess_vorhersage_se,
    loess_obere_schranke = loess_vorhersage + qt(0.975, loess_vorhersage_df) *
      loess_vorhersage_se,
    # transform to original scale
    loess_untere_schranke = 10 ^ loess_untere_schranke,
    loess_obere_schranke = 10 ^ loess_obere_schranke,
    loess_vorhersage = 10 ^ (loess_vorhersage),
    viruslast = 10 ^ (log_viruslast)
  ) %>%
  # select and rename relevant variables
  select(
    datum,
    n = n_non_na,
    anteil_bev,
    viruslast,
    contains("loess"),-contains("vorhersage_df"),-contains("vorhersage_se"),
    normalisierung,
    typ
  ) %>%
  # drop na entries
  filter(!is.na(viruslast))
