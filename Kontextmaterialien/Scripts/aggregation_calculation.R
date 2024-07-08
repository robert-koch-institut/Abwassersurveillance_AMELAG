# read in data
df <- read_tsv(here(read_data_here,
                    "amelag_einzelstandorte.tsv"))

# create aggregated data (aggregated over all sites)
df_agg <- df %>%
  # create log values
  mutate(log_viruslast = log10(viruslast)) %>%
  # for each site, compute 7-day averages
  group_by(standort) %>%
  mutate_at(vars(contains("viruslast")),
            ~ data.table::frollmean(., 7, align = "right", na.rm = TRUE)) %>%
  ungroup() %>%
  # create week and year variable
  mutate(
    KW = lubridate::week(datum),
    Jahr = lubridate::year(datum),
    Tag = lubridate::wday(datum, week_start = 1)
  ) %>%
  # take only wednesday values (i.e. averages from the last 7 days starting/ending from
  # wednesdays)
  filter(Tag == 3, !is.na(log_viruslast)) %>%
  # remove sites without available weight
  filter(!is.na(einwohner)) %>%
  group_by(datum) %>%
  # compute weights for loess calculation below
  mutate(weights = 1 / var_weighted(x = log_viruslast, wt = einwohner)) %>%
  # count contributing sites per Wednesday
  mutate(n_non_na = sum(!is.na(log_viruslast))) %>%
  # compute weighted means
  mutate_at(vars(contains("viruslast")),
            # if at least a certain amount of sites provides data
            ~ if (mean(n_non_na) < min_obs) {
              NA
            } else
            {
              weighted.mean(., (einwohner), na.rm = TRUE)
            }) %>%
  # drop NAs
  filter(!is.na(log_viruslast)) %>%
  # aggregate over sites
  summarise(
    n_non_na = mean(n_non_na, na.rm = TRUE),
    log_viruslast = mean(log_viruslast, na.rm = TRUE),
    anteil_bev = sum(einwohner, na.rm = TRUE) / pop,
    weights = mean(weights, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  # standardize weights
  mutate(weights = weights / mean(weights, na.rm = TRUE)) %>%
  arrange(datum) %>%
  # expand for predictions
  pad(interval = "day")

# compute loess predictions
pred <- df_agg %>%
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
                          weights = sqrt(.x$weights[!is.na(.x$log_viruslast)])
                        ),
                        newdata = data.frame(x = .x$obs),
                        se = TRUE
                      ))) %>%
  select(pred) %>%
  unnest(cols = c(pred))

df_agg <- df_agg %>%
  # add columns relevant for predictions
  add_column(
    loess_vorhersage = pred[[1]]["fit"] %>% unlist(),
    loess_vorhersage_se = pred[[1]]["se.fit"] %>% unlist(),
    loess_vorhersage_df = pred[[1]]["df"] %>% unlist()
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
