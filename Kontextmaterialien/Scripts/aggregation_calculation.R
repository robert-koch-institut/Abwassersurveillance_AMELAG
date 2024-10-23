# read in data
df <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv"),
               show_col_types = FALSE)

# create aggregated data (aggregated over all sites)
df_agg <- df %>%
  # create log values
  mutate(log_viruslast = log10(viruslast)) %>%
  # generate week starting on Thursdays
  mutate(
    Tag = lubridate::wday(datum, week_start = 1),
    is_donnerstag = ifelse(Tag == 4, 1, 0),
    don_woche = cumsum(is_donnerstag)
  ) %>%
  # for each site, compute 7-day averages
  group_by(standort, typ, don_woche) %>%
  mutate_at(vars(contains("viruslast")), ~ mean(., na.rm = TRUE)) %>%
  ungroup() %>%
  # take only wednesday values (i.e. averages from the last 7 days starting/ending from
  # wednesdays)
  filter(Tag == 3, !is.na(log_viruslast)) %>%
  # remove sites without available weight
  filter(!is.na(einwohner))

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
  # ensure that influenza gesamt is sum of the single viruses
  mutate(
    log_viruslast = ifelse(typ == "influenza_gesamt", log10(sum(
      10 ^ log_viruslast[typ %in% c("influenza_a", "influenza_b")], na.rm = TRUE
    )), log_viruslast),
    # drop created zeros (if only NAs are summed up, a zero is created)
    log_viruslast = ifelse(log_viruslast < 0.0000001, NA, log_viruslast)
  ) %>%
  ungroup()

# compute loess predictions
pred <- df_agg %>%
  group_by(typ) %>%
  nest() %>%
  mutate(pred = map(data, ~
                      predict(
                        loess.as(
                          .x$obs[!is.na(.x$log_viruslast)],
                          .x$log_viruslast[!is.na(.x$log_viruslast)],
                          criterion = "aicc",
                          family = "gaussian",
                          degree = 2,
                          control = loess.control(surface = "direct"),
                          weights = sqrt(.x$weights[!is.na(.x$log_viruslast)])
                        ),
                        newdata = data.frame(x = .x$obs),
                        se = TRUE
                      ))) %>%
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
  )
