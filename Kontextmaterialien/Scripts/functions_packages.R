# install (if not done yet) and load required packages
pacman::p_load(here,
               rio,
               tidyverse,
               reshape,
               padr,
               fANCOVA,
               writexl,
               scales,
               lubridate)

# population in Germany at end of 2022 (should match more or less date of
# collection of connected inhabitants of treatment plants)
# https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Bevoelkerungsstand/_inhalt.html,
# accessed on 25/10/2023
pop <- 84358845

# define function that computes variance of a weighted mean
var_weighted <- function(x = NULL, wt = NULL) {
  xm = weighted.mean(x, wt)
  return(sum(wt * (x - xm) ^ 2) / (sum(wt) - 1) / sum(wt))
}

# function for substituting german umlaute
replace_umlauts <- function(text) {
  # Replace umlauts with their ASCII counterparts
  text <- gsub("ä", "ae", text)
  text <- gsub("ö", "oe", text)
  text <- gsub("ü", "ue", text)
  text <- gsub("Ä", "Ae", text)
  text <- gsub("Ö", "Oe", text)
  text <- gsub("Ü", "Ue", text)
  text <- gsub("ß", "ss", text)
  return(text)
}

# function to extract predictions with certain name from list
extract_prediction <- function(lis = NULL, extract = NULL) {
  extracted <- lis[sapply(names(lis), function(x)
    grepl(paste0("^", extract, "$"), x))] %>%
    unlist()
  return(extracted)
}

# function to set english names to states
eng_county <- function(Bundesland = "Bayern") {
  case_when(
    Bundesland == "Bayern" ~ "Bavaria",
    Bundesland == "Hessen" ~ "Hesse",
    Bundesland == "Mecklenburg-Vorpommern" ~ "Mecklenburg-Western Pomerania",
    Bundesland == "Niedersachsen" ~ "Lower Saxony",
    Bundesland == "Nordrhein-Westfalen" ~ "North Rhine-Westphalia",
    Bundesland == "Rheinland-Pfalz" ~ "Rhineland-Palatinate",
    Bundesland == "Sachsen" ~ "Saxony",
    Bundesland == "Sachsen-Anhalt" ~ "Saxony-Anhalt",
    Bundesland == "Thüringen" ~ "Thuringia",
    .default = Bundesland
  )
}

# function to plot sites with few data
plot_not_enough_data <- function(county = county) {
  p1 <-  ggplot() +
    annotate(
      "text",
      x = 0.5,
      y = 0.5,
      label = "Bald verfügbar.",
      size = 5,
      color = "black",
      hjust = 0.5,
      vjust = 0.5
    ) +
    theme_void() +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5))
  return(p1)
}

# loq plot
loq_plot <- function(plot_data = plot_data, virus = "Influenza A") {
  # select pathogen
  plot_data <- plot_data %>%
    filter(typ == !!(virus))
  
  # add row for zero values
  plot_data_y <- plot_data %>%
    complete(woche, nesting(unter_bg), fill = list(n = 0, proportion = 0.0)) %>%
    # add year variable (year according to Wednesday of the calender week)
    mutate(Y = year(woche + 2))
  
  # sum observations per week
  plot_data_w <- plot_data_y %>%
    group_by(Y, woche) %>%
    summarise(n = sum(n))
  
  # set some graphic parameters
  f0 <- 1.05
  fh <- .2
  annotation_text_size = 1.6
  
  # store maximum number of observations per week
  n_max <- max(plot_data_w %>% pull(n))
  
  # basic plot
  p <- ggplot(data = plot_data_y, aes(x = woche)) +
    geom_bar(
      stat = "identity",
      aes(y = proportion, fill = unter_bg),
      color = "black",
      linewidth = .2,
      alpha = .8
    ) +
    theme_minimal() +
    theme(legend.position = "bottom") +
    scale_x_date(
      date_breaks = "4 week",
      labels = function(x) {
        week_labels <- lubridate::isoweek(x)
        year_labels <- lubridate::isoyear(x)
        paste0(week_labels, "\n", year_labels)
      },
      expand = c(0, 0)
    ) +
    scale_y_continuous(
      expand = expansion(mult = c(0, .011)),
      labels = scales::percent,
      breaks = .25 * c(0:4),
      minor_breaks = NULL
    )  +
    geom_text(aes(
      label = n,
      y = ifelse(unter_bg == 0, -0.05, 1.01),
      vjust = ifelse(unter_bg == 0, 2, 0)
    ),
    position = position_stack(),
    size = annotation_text_size) +
    labs(x = "Kalenderwoche", y = "Anteil der Abwasserstichproben") +
    geom_rect(
      data = plot_data_w,
      aes(
        ymin = f0,
        ymax = f0 + fh,
        xmin = woche - 3.5 * .9,
        xmax = woche + 3.5 * .9
      ),
      fill = "white",
      color = "black",
      linewidth = .2,
      show.legend = F
    ) +
    geom_rect(
      data = plot_data_w %>% filter(n == n_max),
      aes(
        ymin = f0,
        ymax = f0 + fh * round(n / n_max, digits = 1),
        xmin = woche - 3.5 * .9,
        xmax = woche + 3.5 * .9
      ),
      fill =  "darkgray",
      color = "black",
      linewidth = .2,
      alpha = .8,
      show.legend = F
    ) +
    geom_rect(
      data = plot_data_w %>% filter(n != n_max),
      aes(
        ymin = f0,
        ymax = f0 + fh * round(n / n_max, digits = 1),
        xmin = woche - 3.5 * .9,
        xmax = woche + 3.5 * .9
      ),
      fill = "lightgray",
      color = "black",
      linewidth = .2,
      alpha = .8,
      show.legend = F
    ) +
    geom_text(data = plot_data_w,
              aes(
                label = n,
                y = f0 + fh + .01,
                vjust = 0
              ),
              size = annotation_text_size) +
    theme(
      panel.spacing = unit(.1, 'lines'),
      strip.text.x = element_text(
        angle = 0,
        hjust = 0,
        vjust = 0
      )
    ) +
    scale_fill_manual(
      values = RColorBrewer::brewer.pal(12, "Set3")[c(5, 7)],
      name = paste(virus, "Nachweise", sep = " "),
      breaks = c("0", "1"),
      labels = c("positiv (> BG)", "negativ (< BG)")
    )
  
  # save plot
  ggsave(
    here(results_here, virus, "Nachweisbarkeit_Anteile.png"),
    plot = p,
    width = 60,
    height = 30,
    units = "cm"
  )
  
}

aggregation <- function(df = df_agg,
                        virus = "sars",
                        weighting = TRUE) {
  # filter by selected virus
  df <- df %>%
    filter(typ == !!(virus))
  
  # if weighting then use inhabitants as weights, else set weights to 1
  if (weighting)
    df <- df %>%
      mutate(weighting_var = einwohner)
  else
    df <- df %>%
      mutate(weighting_var = 1)
  
  # set seed for replicability
  set.seed(22)
  df <- df %>%
    # for non-normalized data below limit of detection, draw random value below
    # limit of detection to introduce some noise for calculation of the variance
    # of the mean (otherwise, the mean for a week over all places might have zero
    # variance)
    mutate(sim_log = if (!use_normalized_data) {
      ifelse(unter_bg == "ja",
             runif(n(), 0.9*!!sym(paste0("log_",viruslast_untersucht)),
                   1.1 * !!sym(paste0("log_",viruslast_untersucht))),
             !!sym(paste0("log_",viruslast_untersucht)))
    } else {
      !!sym(paste0("log_",viruslast_untersucht))
    }) %>%
    group_by(th_week) %>%
    # compute weights for loess curve, these are the inverse values of the variance
    # of the (weighted) mean of the observations
    mutate(weights = (1 / var_weighted(x = sim_log, wt = weighting_var))) %>%
    # count contributing sites per Wednesday
    mutate(n_non_na = sum(!is.na(!!sym(
      viruslast_untersucht
    )))) %>%
    # compute weighted means
    mutate_at(vars(contains("viruslast")), # if at least a certain amount of sites provides data
              ~ if (mean(n_non_na) < min_obs_agg) {
                NA
              } else
              {
                weighted.mean(., (weighting_var), na.rm = TRUE)
              }) %>%
    filter(!is.na(log_viruslast)) %>%
    mutate(
      n_non_na = mean(n_non_na, na.rm = TRUE),
      log_viruslast = mean(log_viruslast, na.rm = TRUE),
      anteil_bev = sum(einwohner, na.rm = TRUE) / pop,
      weights = mean(weights, na.rm = TRUE),
    ) %>%
    ungroup() %>%
    filter(Tag == 3) %>%
    distinct(datum, .keep_all = T) %>%
    # standardize means
    mutate(weights = weights / mean(weights, na.rm = TRUE)) %>%
    arrange(datum) %>%
    dplyr::select(typ, datum, n_non_na, log_viruslast, anteil_bev, weights) %>%
    # expand for predictions
    pad(interval = "day") %>%
    fill(typ, .direction = "updown") %>%
    mutate(obs = row_number())
  return(df)
}
