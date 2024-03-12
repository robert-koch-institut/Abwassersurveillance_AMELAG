# read in data
df_agg <- read_tsv(here(read_data_here,
                        "amelag_aggregierte_kurve.tsv"))

# should log data be shown?
if (show_log_data)
{
  df_agg  <-
    df_agg  %>%
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

df_agg %>%
  ggplot() +
  geom_ribbon(aes(ymin = loess_untere_schranke,
                  ymax = loess_obere_schranke),
              # shadowing cnf intervals
              fill = "lightblue") +
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
       x = "Datum")

# save plot
ggsave(
  here(results_here, paste0("aggregierte_Kurve", filename_add, ".pdf")),
  width = 30,
  height = 15,
  units = "cm"
)
