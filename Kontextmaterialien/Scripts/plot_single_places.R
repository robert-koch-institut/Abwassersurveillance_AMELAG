# read in data for single treatment plants
data_plots <- data_combined

# should log data be shown?
if (show_log_data)
{
  data_plots <-
    data_plots %>%
    mutate_at(
      vars(
        loess_vorhersage,
        loess_obere_schranke,
        loess_untere_schranke,
        viruslast
      ),
      ~ log10(.)
    )
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

data_plots <- data_plots %>%
  # set date of laboratory / method change
  mutate(Lab_change_date = as.Date(ifelse(laborwechsel == "ja", datum, NA)),
         # replace umlaute
         label = replace_umlauts(standort))

# export data for single places
data_plots %>%
  select(-Lab_change_date, -labor, -loess_period) %>%
  mutate(wochentag = lubridate::wday(datum, label = TRUE, week_start = 1)) %>%
  arrange(label, datum) %>%
  group_by(typ, label) %>%
  group_walk( ~ write_xlsx(.x, here(
    results_here,
    .y$typ,
    "Single_Sites",
    paste0(.y$label, filename_add, "_Abwasserdaten.xlsx")
  )))

# save plots for single places
data_plots %>%
  # for speeding up calculations drop NAs
  filter(!is.na(viruslast)) %>%
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
            aes(
              ymin = loess_untere_schranke,
              ymax = loess_obere_schranke,
              group = interaction(loess_period, labor)
            ),
            fill = "lightblue"
          ) +
          aes(x = datum, y = viruslast) +
          geom_point(aes(color = unter_bg)) +
          geom_line(
            aes(datum, y = loess_vorhersage, group = interaction(loess_period, labor)),
            linewidth = 1
          ) +
          scale_color_manual(
            values = c("black", "grey"),
            name = "Nachweis",
            breaks = c("nein", "ja"),
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
