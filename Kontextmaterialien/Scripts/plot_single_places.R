# read in data for single treatment plants
data_combined <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv")) %>%
  select(-loess_aenderung)

# should log data be shown?
if (show_log_data)
{
  data_combined <-
    data_combined %>%
    mutate_at(vars(contains("loess"), viruslast), ~ log10(.))
  ytit <-
    expression(atop("Viruslast im Abwasser", atop(paste(
      "in ", log[10], " Genkopien / Liter"
    ))))
  # also change name of saved files if log applied, else not
  filename_add <- "_log"
} else {
  ytit <-
    expression(atop("Viruslast im Abwasser", atop(paste(
      "in Genkopien / Liter"
    ))))
  # also change name of saved files if log applied, else not
  filename_add <- ""
}

data_combined <- data_combined %>%
  # set date of laboratory / method change
  mutate(Lab_change_date = as.Date(ifelse(laborwechsel == "ja", datum, NA))) %>%
  group_by(standort, typ) %>%
  # create variable indicating whether minimum numbers of observations are available
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
  group_by(typ, label) %>%
  group_walk(~ write_xlsx(.x, here(
    results_here,
    .y$typ,
    "Single_Sites",
    paste0(.y$label, filename_add, "_Abwasserdaten.xlsx")
  )))

if ((data_combined %>% filter(min_obs_exceeded < 1) %>% nrow()) > 0)
  # export data for single places without sufficient observations
  data_combined %>%
  filter(min_obs_exceeded < 1) %>%
  select(standort, typ, datum, viruslast, label) %>%
  mutate(wochentag = lubridate::wday(datum, label = TRUE, week_start = 1)) %>%
  arrange(label, datum) %>%
  group_by(typ, label) %>%
  group_walk(~ write_xlsx(.x, here(
    results_here,
    .y$typ,
    "Single_Sites",
    paste0(.y$label, filename_add, "_Abwasserdaten.xlsx")
  )))

# save plots for single places with sufficient observations
data_combined %>%
  filter(min_obs_exceeded > 0) %>%
  group_by(typ, label) %>%
  group_map(
    ~
      ggsave(
        here(
          results_here,
          .y$typ,
          "Single_Sites",
          paste0(.y$label, filename_add, "_Loess_Kurve.pdf")
        ),
        ggplot(data = .x) +
          geom_ribbon(
            aes(ymin = loess_untere_schranke, ymax = loess_obere_schranke),
            # shadowing cnf intervals
            fill = "lightblue"
          ) +
          aes(x = datum, y = viruslast) +
          geom_point(aes(color = unter_BG)) +
          geom_line(aes(datum, y = loess_vorhersage), linewidth = 1) +
          scale_color_manual(
            values = c("black", "grey"),
            name = "Nachweis",
            breaks = c(FALSE, TRUE),
            labels = c("positiv (> BG)", "negativ (< BG)")
          ) +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45)) +
          scale_x_date(date_breaks = "month", date_labels = "%b %y") +
          scale_y_continuous(labels = ~ format(.x, scientific = FALSE)) +
          labs(y =  ytit, x = "Datum") +
          geom_vline(
            xintercept = as.numeric(.x$Lab_change_date),
            linetype = "dashed"
          ),
        width = 30,
        height = 15,
        units = "cm"
      )
  )

if ((data_combined %>% filter(min_obs_exceeded < 1) %>% nrow()) > 0)
  # save plots for single places without sufficient observations
  data_combined %>%
  filter(min_obs_exceeded < 1) %>%
  group_by(typ, label) %>%
  group_map(
    ~
      ggsave(
        here(
          results_here,
          .y$typ,
          "Single_Sites",
          paste0(.y$label, filename_add, "_Loess_Kurve.pdf")
        ),
        ggplot(data = .x) +
          aes(x = datum, y = viruslast) +
          geom_point(aes(color = unter_BG)) +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45))  +
          scale_color_manual(
            values = c("black", "grey"),
            name = "Nachweis",
            breaks = c(FALSE, TRUE),
            labels = c("positiv (> BG)", "negativ (< BG)")
          ) +
          scale_x_date(date_breaks = "weeks", date_labels = "%U-%Y") +
          geom_vline(
            xintercept = as.numeric(.x$Lab_change_date),
            linetype = "dashed"
          ) +
          scale_y_continuous(labels = ~ format(.x, scientific = FALSE)) +
          labs(y =  ytit, x = "Kalenderwoche"),
        width = 30,
        height = 15,
        units = "cm"
      )
  )
