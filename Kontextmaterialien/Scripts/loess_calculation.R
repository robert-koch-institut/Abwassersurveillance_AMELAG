# read in data
df <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv"),
               show_col_types = FALSE)

# store column names
df_colnames <- names(df)

# drop loess estimates and derived quantities
df <- df %>%
  select(-contains("loess"), -trend) %>%
  # drop sites with too few measurements
  group_by(standort, typ) %>%
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
  arrange(standort, typ, datum)

# compute loess predictions
pred <- df %>%
  group_by(standort, typ) %>%
  mutate(obs = row_number()) %>%
  nest() %>%
  mutate(pred = map(data, ~
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
                      ))) %>%
  select(pred) %>%
  unnest(cols = c(pred))

# store list
pred_list <- pred[, "pred"]$pred

# store number of observations per group
reps <- df %>%
  group_by(standort, typ) %>%
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
  group_by(standort, typ) %>%
  mutate(
    # compute minimum value
    min_log_viruslast = min(log_viruslast, na.rm = T),
    # check it af least one value below loq
    at_least_one_loq = sum(unter_bg=="ja", na.rm = TRUE) > 0,
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
    loess_vorhersage = 10 ^ (loess_vorhersage),
    viruslast = 10 ^ (log_viruslast)
  ) %>%
  # drop variables
  select(-min_log_viruslast, -at_least_one_loq)

# compute changes over time (trend analysis)
change <-
  df %>%
  select(standort, typ, datum, loess_vorhersage) %>%
  arrange(standort, datum) %>%
  filter(!is.na(loess_vorhersage)) %>%
  group_by(standort, typ) %>%
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
  change %>%
  arrange(standort, typ, datum) %>%
  # and merge with whole data set
  right_join(df  %>% filter(!is.na(loess_vorhersage)), by = c("standort", "typ", "datum")) %>%
  arrange(standort, datum) %>%
  # create day variable
  mutate(tag = lubridate::wday(datum, week_start = 1))

# add data with few measurements
data_combined <- data_combined %>%
  bind_rows(df_small)

# clean up
rm(change, df, df_small, pred, pred_list, reps)

# clean up data
data_combined <- data_combined %>%
  mutate(trend = ifelse(tag != 3, NA, trend)) %>%
  group_by(standort) %>%
  mutate(trend = ifelse(datum == min(datum), "keine Daten vorhanden", trend)) %>%
  ungroup() %>%
  select(all_of(df_colnames))
