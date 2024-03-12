# read in data for single treatment plants
data_combined <- read_tsv(here(read_data_here,
                               "amelag_einzelstandorte.tsv")) %>% 
  select(-loess_aenderung)

# should log data be shown?
if (show_log_data)
{
  data_combined <-
    data_combined %>%
    mutate_at(vars(contains("loess"), viruslast),
              ~ log10(.))
  ytit <-
    expression(atop("Viruslast im Abwasser",
                    atop(paste(
                      "in ", log[10],
                      " Genkopien / Liter"
                    ))))
  # also change name of saved files if log applied, else not
  filename_add <- "_log"
} else {
  ytit <-
    expression(atop("Viruslast im Abwasser",
                    atop(paste(
                      "in Genkopien / Liter"
                    ))))
  # also change name of saved files if log applied, else not
  filename_add <- ""
}

# create variable indicating whether minimum numbers of observations are available
data_combined <- data_combined %>%
  group_by(standort) %>%
  mutate(min_obs_exceeded = ifelse(sum(!is.na(viruslast)) >= min_obs, 1, 0)) %>%
  ungroup()

# replace umlaute
data_combined <- data_combined %>%
  mutate(label = replace_umlauts(standort))

# export data for single places with sufficient observations
data_combined %>%
  filter(min_obs_exceeded > 0) %>%
  select(-min_obs_exceeded) %>%
  mutate(wochentag = lubridate::wday(datum, label = TRUE, week_start = 1)) %>%
  arrange(label, datum) %>%
  group_by(label) %>%
  group_walk( ~ write_xlsx(.x, here(
    results_single_places_here,
    paste0(.y$label, filename_add, "_Abwasserdaten.xlsx")
  )))

if ((data_combined %>% filter(min_obs_exceeded < 1) %>% nrow())>0)
# export data for single places without sufficient observations
data_combined %>%
  filter(min_obs_exceeded < 1) %>%
  select(standort, datum, viruslast, label) %>%
  mutate(wochentag = lubridate::wday(datum, label = TRUE, week_start = 1)) %>%
  arrange(label, datum) %>%
  group_by(label) %>%
  group_walk( ~ write_xlsx(.x, here(
    results_single_places_here,
    paste0(.y$label, filename_add, "_Abwasserdaten.xlsx")
  )))

# save plots for single places with sufficient observations
data_combined %>%
  group_by(label) %>%
  group_map(
    ~
      ggsave(
        here(
          results_single_places_here,
          paste0(.y$label, filename_add, "_Loess_Kurve.pdf")
        ),
        ggplot(data = .x) +
          geom_ribbon(
            aes(ymin = loess_untere_schranke,
                ymax = loess_obere_schranke),
            # shadowing cnf intervals
            fill = "lightblue"
          ) +
          aes(x = datum, y = viruslast) +
          geom_point(colour = "grey") +
          geom_line(aes(datum,
                        y = loess_vorhersage),
                    linewidth = 1) +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45)) +
          scale_x_date(date_breaks = "month",
                       date_labels = "%b %y") +
          scale_y_continuous(labels = ~ format(.x, scientific = FALSE)) +
          labs(y =  ytit,
               x = "Datum"),
        width = 30,
        height = 15,
        units = "cm"
      )
  )

if ((data_combined %>% filter(min_obs_exceeded < 1) %>% nrow())>0)
# save plots for single places without sufficient observations
data_combined %>%
  filter(min_obs_exceeded < 1) %>%
  group_by(label) %>%
  group_map(
    ~
      ggsave(
        here(
          results_single_places_here,
          paste0(.y$label, filename_add, "_Loess_Kurve.pdf")
        ),
        ggplot(data = .x) +
          aes(x = datum, y = viruslast) +
          geom_point(colour = "grey") +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45)) +
          scale_x_date(date_breaks = "weeks",
                       date_labels = "%U-%Y") +
          scale_y_continuous(labels = ~ format(.x, scientific = FALSE)) +
          labs(y =  ytit,
               x = "Kalenderwoche"),
        width = 30,
        height = 15,
        units = "cm"
      )
  )
