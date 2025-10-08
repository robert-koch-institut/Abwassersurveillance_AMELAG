# read in data
df <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv"),
               show_col_types = FALSE) %>%
  # rename RSV A/B to avoid problems when saving data
  mutate(typ = ifelse(typ == "RSV A/B", "RSV AB", typ)) %>%
  # remove unreliable / variable Influenza data from Dresden from aggregation
  filter(!(
    standort == "Dresden" &
      typ %in% c("Influenza A", "Influenza B" , "Influenza A+B")
  ))

# generate weeks starting on Thursday
thursday_data <-
  df %>%
  distinct(datum) %>%
  arrange(datum) %>%
  mutate(
    Tag = lubridate::wday(datum, week_start = 1),
    is_thursday = ifelse(Tag == 4, 1, 0),
    th_week = cumsum(is_thursday)
  ) %>%
  dplyr::select(datum, th_week, Tag)

# create aggregated data (aggregated over all sites)
df_agg <- df %>%
  left_join(thursday_data) %>%
  group_by(standort, typ, th_week) %>%
  # complete data
  fill(unter_bg, .direction = "updown") %>%
  # create log values
  mutate(log_viruslast = log10(!!sym(viruslast_untersucht))) %>%
  ungroup()

df_agg <- df_agg %>%
  arrange(standort, typ, datum) %>%
  # for each site, compute 7-day averages
  group_by(standort, typ, th_week) %>%
  mutate_at(vars(contains("viruslast")), ~ mean(., na.rm = TRUE)) %>%
  # take only one value per week, site
  filter(datum == max(datum, na.rm = TRUE)) %>%
  ungroup() %>%
  # remove sites without available weight
  filter(!is.na(einwohner), !is.na(log_viruslast))

df_agg <- df_agg %>%
  # calculate unweighted means over the weeks as these unweighted means can be
  # used to calculate differnces between site/lab combination from these means.
  # in this way, average differences in the viral loads that are site/lab
  # specific can be adjusted for.
  group_by(typ, th_week) %>%
  mutate(mean_log_viruslast = mean(log_viruslast)) %>%
  ungroup() %>%
  # calculate differences from these means
  mutate(log_viruslast_dev = log_viruslast - mean_log_viruslast) %>%
  group_by(standort, typ) %>%
  mutate(
    # add lab number per site (first lab gets 0, second lab gets 1 etc.)
    laborwechsel_numerisch = ifelse(laborwechsel == "ja", 1, 0),
    labor = cumsum(laborwechsel_numerisch),
  ) %>%
  ungroup() %>%
  # average over these for each virus/site/lab combination
  group_by(typ, standort, labor) %>%
  mutate(log_viruslast_dev = mean(log_viruslast_dev)) %>%
  ungroup() %>%
  # adjust for these deviations
  mutate(log_viruslast = log_viruslast - log_viruslast_dev) %>%
  # drop variables no longer needed
  select(-mean_log_viruslast,
         -log_viruslast_dev,
         -labor,-laborwechsel_numerisch)

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

# compute gam predictions
pred <- df_agg %>%
  group_by(typ) %>%
  nest() %>%
  mutate(pred = pmap(list(data, typ), function(d_grp, typ) {
    # clean data
    d <- d_grp %>% filter(!is.na(log_viruslast), !is.na(obs))
    
    # helper to fit GAM with a given k (basis dimension) and bs (spline basis)
    fit_gam <- function(k, bs, method = "GCV.Cp") {
      mgcv::gam(log_viruslast ~ s(obs, k = k, bs = bs),
                method = method,
                weights = sqrt(weights),     
                data = d)
    }
    
    # Choose a default k: default is given to mgcv default
    k_main <- -1
    
    # try to fit model with adaptive smooth
    fit <- tryCatch(
      fit_gam(k_main, bs = "ad"),
      warning = function(w) {
        message(
          "Warning in pathogen ",
          typ,
          conditionMessage(w),
          " — retrying without adaptive smooth = "
        )
        # in case of error (mostly due to small observations) do not use adaptive smoothing
        tryCatch(
          fit_gam(k_main, bs = "bs"),
          error = function(e)
            NULL
        )
      },
      error = function(e) {
        message("Error in pathogen ", ": ", conditionMessage(e))
        list(
          df = 1,
          fit = d_grp$log_viruslast,
          se.fit = rep(0, nrow(d_grp))
        )
      }
    )
    
    # Predict (on the original group's obs; keep rows aligned)
    p <- tryCatch(
      predict(fit, newdata = d_grp[, "obs", drop = FALSE], se.fit = TRUE),
      error = function(e) {
        message("Predict error in pathogen ", typ, ": ", conditionMessage(e))
        list(
          df = 1,
          fit = d_grp$log_viruslast,
          se.fit = rep(0, nrow(d_grp))
        )
      }
    )
    list(
      df = fit$df.residual,
      fit = as.numeric(p$fit),
      se.fit = as.numeric(p$se.fit)
    )
  })) %>%
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
    loess_untere_schranke = 10^loess_untere_schranke,
    loess_obere_schranke = 10^loess_obere_schranke,
    loess_vorhersage = 10^(loess_vorhersage),
    !!sym(viruslast_untersucht) := 10^(log_viruslast)
  ) %>%
  # select and rename relevant variables
  select(
    datum,
    n = n_non_na,
    anteil_bev,
    !!sym(viruslast_untersucht),
    contains("loess"),
    -contains("vorhersage_df"),
    -contains("vorhersage_se"),
    typ
  ) %>%
  # drop na entries
  filter(!is.na(!!sym(viruslast_untersucht)))
