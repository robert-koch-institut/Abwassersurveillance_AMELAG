# read in data
df <- read_tsv(here(read_data_here,
                    "amelag_einzelstandorte.tsv"))

# store column names
df_colnames <- names(df)

# drop loess estimates and derivated quantities
df <- df %>%
  select(standort, bundesland, datum, viruslast, einwohner) %>%
  # drop sites with too few measurements
  group_by(standort) %>%
  mutate(min_obs_exceeded = ifelse(sum(!is.na(viruslast)) >= min_obs, 1, 0)) %>%
  ungroup() %>%
  # create log values
  mutate(log_viruslast = log10(viruslast))

# save data set with too few observations to calculate loess curve,
# this data set is combined with the remaining data further below again
df_small <- df %>%
  filter(min_obs_exceeded < 1)

# save data set with sufficient observations per site to calculate loess curves
df <- df %>%
  filter(min_obs_exceeded > 0) %>% 
  arrange(standort, datum)
  
# compute loess predictions
pred <- df %>%
  group_by(standort) %>%
  mutate(obs = row_number()) %>%
  nest() %>%
  mutate(pred = map(data, ~
                      predict(
                        loess.as(
                          .x$obs[!is.na(.x$log_viruslast)],
                          .x$log_viruslast[!is.na(.x$log_viruslast)],
                          criterion = "gcv",
                          family = "gaussian",
                          degree = 2,
                        ),
                        newdata = data.frame(x = .x$obs),
                        se = TRUE
                      ))) %>%
  select(pred) %>%
  unnest(cols = c(pred))

# store number of observations per group
reps <- df %>%
  group_by(standort) %>%
  summarise(n = n()) %>%
  pull(n)

df <- df %>%
  # add columns relevant for predictions
  add_column(
    loess_vorhersage = pred %>%
      slice(1) %>%
      pull(pred) %>%
      unlist(),
    loess_vorhersage_se = pred %>%
      slice(2) %>%
      pull(pred) %>%
      unlist(),
    loess_vorhersage_df = pred %>%
      slice(4) %>%
      ungroup() %>%
      select(pred) %>%
      pull() %>%
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

# compute changes over time (trend analysis)
change <-
  df %>%
  select(standort, datum,  loess_vorhersage) %>%
  arrange(standort, datum) %>%
  filter(!is.na(loess_vorhersage)) %>%
  group_by(standort) %>%
  # compute relative change
  mutate(loess_aenderung = (loess_vorhersage / lag(loess_vorhersage, 7)) -
           1) %>%
  na.omit() %>%
  # compute whether there is a positive trend using different thresholds
  mutate(
    trend = case_when(
      loess_aenderung > 0.15 ~ "Ansteigend",
      between(loess_aenderung, -0.15, 0.15) ~ "Unverändert",
      loess_aenderung < -0.15 ~ "Fallend"
    )
  ) %>%
  ungroup()  %>%
  select(-loess_vorhersage)

# combine these data frames
data_combined <-
  change %>% select(standort,
                    datum,
                    loess_aenderung,
                    trend) %>%
  arrange(standort, datum) %>%
  # and merge with whole data set
  right_join(df  %>% filter(!is.na(loess_vorhersage)),
             by = c("standort", "datum")) %>%
  arrange(standort, datum) %>%
  # create day variable
  mutate(tag = lubridate::wday(datum, week_start = 1))

# clean up
rm(change, df, pred, reps)

# add data with few measurements
data_combined <- data_combined %>%
  bind_rows(df_small)

# clean up data
data_combined <- data_combined %>%
  mutate(trend = ifelse(tag != 3, NA, trend)) %>%
  group_by(standort) %>%
  mutate(trend = ifelse(datum == min(datum), "keine Daten vorhanden", trend)) %>%
  ungroup() %>%
  select(df_colnames)
