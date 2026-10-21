# read in data
df <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv"),
               show_col_types = FALSE) %>%
  # rename RSV A/B to avoid problems when saving data
  mutate(typ = ifelse(typ == "RSV A/B", "RSV AB", typ),
         .row_id = row_number()) %>%
  # remove unreliable / variable data from aggregation
  left_join(
    discard_rules,
    by = c("standort", "typ"),
    relationship = "many-to-many"
  ) %>%
  group_by(.row_id) %>%
  filter(
    !any(
      datum >= entfernt_vom &
        datum <= coalesce(entfernt_bis, Sys.Date()),
      na.rm = TRUE
    )
  ) %>%
  slice(1) %>%
  ungroup() %>%
  select(-.row_id, -entfernt_vom, -entfernt_bis) %>%
  arrange(datum)

# create aggregated data (aggregated over all sites)
df_agg <- df %>%
  mutate(Tag = lubridate::wday(datum, week_start = 1),
         # generate weeks starting on Thursday
         th_week = as.Date(datum) + ((3 - lubridate::wday(datum, week_start = 1)) %% 7)) %>%
  group_by(standort, typ, th_week) %>%
  # complete data
  fill(unter_bg, .direction = "updown") %>%
  # create log values
  mutate(log_viruslast = log10(!!sym(viruslast_untersucht))) %>%
  ungroup() %>% 
  arrange(typ, standort, datum) %>% 
  group_by(typ, standort) %>%
  mutate(
    # add lab number per site (first lab gets 0, second lab gets 1 etc.)
    laborwechsel_numerisch = ifelse(laborwechsel == "ja", 1, 0),
    labor = cumsum(laborwechsel_numerisch),
  ) %>%
  ungroup() %>% 
  select(-laborwechsel_numerisch, -laborwechsel)

df_agg <- df_agg %>%
  # for each site, compute 7-day averages
  group_by(standort, typ, th_week) %>%
  mutate_at(vars(contains("viruslast")), ~ mean(., na.rm = TRUE)) %>%
  # take only one value per week, site
  filter(datum == max(datum, na.rm = TRUE)) %>%
  ungroup() %>%
  # remove sites without available weight
  filter(!is.na(einwohner), !is.na(log_viruslast))

df_agg <- df_agg %>%
  # calculate weighted means over the weeks as these weighted means can be
  # used to calculate differences between site/lab combination from these means.
  # in this way, average differences in the viral loads that are site/lab
  # specific can be adjusted for.
  group_by(typ, th_week) %>%
  mutate(mean_log_viruslast = weighted.mean(log_viruslast, einwohner)) %>%
  ungroup() %>%
  # calculate differences from these means
  mutate(log_viruslast_dev = log_viruslast - mean_log_viruslast) %>%
  # average over these for each virus/site/lab combination
  group_by(typ, standort, labor) %>%
  mutate(log_viruslast_dev = mean(log_viruslast_dev)) %>%
  ungroup() %>%
  # adjust for these deviations
  mutate(log_viruslast = log_viruslast - log_viruslast_dev) %>%
  # drop variables no longer needed
  select(-mean_log_viruslast,
         -log_viruslast_dev)

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
  # ensure that influenza and rsv gesamt are sums of the single viruses
  mutate(
    log_viruslast = ifelse(typ == "Influenza A+B", log10(sum(
      10^log_viruslast[typ %in% c("Influenza A", "Influenza B")], na.rm = TRUE
    )), log_viruslast),
    log_viruslast = ifelse(typ == "RSV A+B", log10(sum(
      10^log_viruslast[typ %in% c("RSV A", "RSV B")], na.rm = TRUE
    )), log_viruslast),
    # drop created zeros (if only NAs are summed up, a zero is created)
    log_viruslast = ifelse(log_viruslast < 0.0000001, NA, log_viruslast)
  ) %>%
  ungroup()

# Identify new estimation periods after prolonged gaps between actual
# observations. The aggregation() function padded each pathogen's series with
# daily NA rows, so calculate gaps ONLY among measured aggregated values.
# Retain periods with at least min_obs measurements with usable GAM weights.
estimation_periods <- df_agg %>%
  filter(is.finite(log_viruslast), !is.na(datum)) %>%
  arrange(typ, datum) %>%
  group_by(typ) %>%
  mutate(
    days_since_last = as.numeric(datum - lag(datum)),
    new_period = as.integer(!is.na(days_since_last) &
                              days_since_last > wo_meas_period),
    estimation_period = cumsum(new_period)
  ) %>%
  group_by(typ, estimation_period) %>%
  summarise(
    period_start = min(datum),
    period_end = max(datum),
    n_obs = sum(is.finite(weights) & weights > 0),
    .groups = "drop"
  ) %>%
  filter(n_obs >= min_obs)

# Keep daily interpolation dates inside each eligible period, but not the long
# summer break. Periods with fewer than min_obs usable observations have no fit.
df_agg_smoothing <- df_agg %>%
  inner_join(estimation_periods, by = "typ", relationship = "many-to-many") %>%
  filter(datum >= period_start, datum <= period_end) %>%
  select(-period_start, -period_end, -n_obs)

# Fit a weighted adaptive GAM for one period; if it warns or fails, use a
# simpler thin-plate regression spline. Never substitute raw observations for
# failed predictions: that would create an artificial confidence interval.
fit_aggregated_gam_with_fallback <- function(data, typ, estimation_period) {
  empty_result <- list(
    fit = rep(NA_real_, nrow(data)),
    se.fit = rep(NA_real_, nrow(data)),
    df = NA_real_
  )
  
  keep <- is.finite(data$log_viruslast) &
    is.finite(data$obs) &
    is.finite(data$weights) & data$weights > 0
  n_obs <- sum(keep)
  n_unique <- length(unique(data$obs[keep]))
  
  if (n_obs < min_obs || n_unique < 4L) return(empty_result)
  
  k_adapt <- min(max(6L, floor(n_obs / 2.5)), n_unique - 1L)
  m_adapt <- max(1L, floor(k_adapt / 10))
  # k must also be smaller than the number of distinct observation dates.
  k_fallback <- min(10L, n_unique - 1L)
  
  d <- data.frame(
    obs = data$obs[keep],
    y = data$log_viruslast[keep],
    w = sqrt(data$weights[keep])
  )
  
  fit_fallback <- function() {
    tryCatch(
      mgcv::gam(
        y ~ s(obs, bs = "tp", k = k_fallback),
        data = d,
        weights = w,
        family = gaussian()
      ),
      error = function(e) {
        message("GAM fallback failed for ", typ, " period ",
                estimation_period, ": ", conditionMessage(e))
        NULL
      }
    )
  }
  
  warn_or_error <- function(condition) {
    message("Adaptive GAM failed for ", typ, " period ",
            estimation_period, ": ", conditionMessage(condition),
            "; trying a thin-plate spline")
    fit_fallback()
  }
  
  fit <- tryCatch(
    mgcv::gam(
      y ~ s(obs, bs = "ad", k = k_adapt, m = m_adapt),
      data = d,
      weights = w,
      family = gaussian()
    ),
    warning = warn_or_error,
    error = warn_or_error
  )
  if (is.null(fit)) return(empty_result)
  
  prediction <- tryCatch(
    predict(fit, newdata = data.frame(obs = data$obs), se.fit = TRUE),
    error = function(e) {
      message("GAM prediction failed for ", typ, " period ",
              estimation_period, ": ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(prediction)) return(empty_result)
  
  list(
    fit = as.numeric(prediction$fit),
    se.fit = as.numeric(prediction$se.fit),
    df = as.numeric(fit$df.residual)
  )
}

# Predictions are keyed by pathogen AND the original daily observation index.
# This avoids relying on row ordering, which changes when periods are split.
if (nrow(df_agg_smoothing) > 0L) {
  pred <- df_agg_smoothing %>%
    group_by(typ, estimation_period) %>%
    nest() %>%
    mutate(
      results = pmap(
        list(data, typ, estimation_period),
        function(d_grp, virus, period) {
          p <- fit_aggregated_gam_with_fallback(d_grp, virus, period)
          tibble(
            obs = d_grp$obs,
            vorhersage_log = p$fit,
            vorhersage_se = p$se.fit,
            vorhersage_df = rep(p$df, nrow(d_grp))
          )
        }
      )
    ) %>%
    select(typ, estimation_period, results) %>%
    unnest(results)
} else {
  # Preserve the join schema when no pathogen has an eligible period.
  pred <- tibble(
    typ = character(),
    estimation_period = integer(),
    obs = integer(),
    vorhersage_log = numeric(),
    vorhersage_se = numeric(),
    vorhersage_df = numeric()
  )
}

# Join all fitted periods to the complete daily time series. Rows in the
# summer break and in insufficiently sampled periods remain, with NA fits.
df_agg <- df_agg %>%
  left_join(pred, by = c("typ", "obs"), relationship = "many-to-one") %>%
  mutate(
    # Use the period-specific residual degrees of freedom for the CI.
    critical_t = if_else(is.finite(vorhersage_df) & vorhersage_df > 0,
                         qt(0.975, vorhersage_df), NA_real_),
    untere_schranke = 10^(vorhersage_log - critical_t * vorhersage_se),
    obere_schranke = 10^(vorhersage_log + critical_t * vorhersage_se),
    vorhersage = 10^vorhersage_log,
    !!sym(viruslast_untersucht) := 10^log_viruslast
  ) %>%
  # Keep old output names, plus the estimation period needed by plotting.
  select(
    datum,
    n = n_non_na,
    anteil_bev,
    !!sym(viruslast_untersucht),
    vorhersage,
    untere_schranke,
    obere_schranke,
    typ,
    estimation_period
  ) %>%
  arrange(typ, datum)

# IMPORTANT: do not filter on non-missing measurements here: keeping NA days
# allows curves to stop and restart at the actual estimation boundaries.
