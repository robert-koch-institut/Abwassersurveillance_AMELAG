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
loq_plot <- function(plot_data = plot_data, virus = "Influenza-A") {
  # select pathogen
  plot_data <- plot_data %>%
    filter(typ == !!(virus))
  
  # basic plot
  p <- ggplot(data = plot_data, aes(x = woche, y = proportion, fill = unter_bg)) +
    geom_bar(stat = "identity") +
    theme_classic() +
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
    scale_y_continuous(expand = c(0, 0), labels = scales::percent) +
    geom_text(aes(label = n), position = position_stack(vjust = 0.5)) +
    labs(x = "Kalenderwoche", y = "Anteil der Abwasserstichproben") +
    scale_fill_manual(
      values = c("#CE7B47", "#EAC66C"),
      name = paste(virus, "Nachweise", sep = " "),
      breaks = c("0", "1"),
      labels = c("positiv (> BG)", "negativ (< BG)")
    )
  
  # save plots
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
      mutate(weighting_var = einwohner) else
    df <- df %>%
      mutate(weighting_var = 1)
  
  # set seed for replicability
  set.seed(22)
  df <- df %>%
    # for non-normalized data below limit of detection, draw random value below
    # limit of detection to introduce some noise for calculation of the variance
    # of the mean (otherwise, the mean for a week over all places might have zero
    # variance)
    mutate(
      viruslast = ifelse(
        unter_bg == "ja" & normalisierung == "nein",
        runif(n(), 0.00001, 2 * viruslast),
        viruslast
      ),
      sim_log = log10(viruslast)
    ) %>% 
    group_by(th_week) %>%
    # compute weights for loess curve, these are the inverse values of the variance
    # of the (weighted) mean of the observations
    mutate(weights = (1 / var_weighted(x = sim_log, wt = weighting_var))) %>%
    # count contributing sites per Wednesday
    mutate(n_non_na = sum(!is.na(viruslast))) %>%
    # compute weighted means
    mutate_at(vars(contains("viruslast")), # if at least a certain amount of sites provides data
              ~ if (mean(n_non_na) < min_obs) {
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
      normalisierung = normalisierung[1]
    ) %>%
    ungroup() %>%
    filter(Tag == 3) %>%
    distinct(datum, .keep_all = T) %>%
    # standardize means
    mutate(weights = weights / mean(weights, na.rm = TRUE)) %>%
    arrange(datum) %>%
    dplyr::select(typ,
                  datum,
                  n_non_na,
                  log_viruslast,
                  anteil_bev,
                  weights,
                  normalisierung) %>%
    # expand for predictions
    pad(interval = "day") %>%
    fill(typ, .direction = "updown") %>%
    mutate(obs = row_number())
  return(df)
}
