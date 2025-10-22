# read in data
df_agg <- read_tsv(here(read_data_here, "amelag_aggregierte_kurve.tsv")) %>%
  # rename RSV A/B to avoid problems when saving data
  mutate(typ = ifelse(typ == "RSV A/B", "RSV AB", typ))

# should log data be shown?
if (show_log_data)
{
  df_agg  <-
    df_agg  %>%
    mutate_at(vars(contains("vorhersage"), contains("schranke"), !!sym(viruslast_untersucht)), ~ log10(.))
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

# create and save plot for each pathogen
df_agg %>%
  group_by(typ) %>%
  group_map(
    ~ ggsave(
      here(
        results_here,
        .y$typ,
        paste0("aggregierte_Kurve", filename_add, ".pdf")
      ),
      ggplot(data = .x) +
        geom_ribbon(
          aes(ymin = untere_schranke, ymax = obere_schranke),
          # shadowing cnf intervals
          fill = "lightblue"
        ) +
        aes(x = datum, y = !!sym(viruslast_untersucht)) +
        geom_point(colour = "grey") +
        geom_line(aes(datum, y = vorhersage), linewidth = 1) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45)) +
        scale_x_date(date_breaks = "month", date_labels = "%b %y") +
        scale_y_continuous(labels = ~ format(.x, scientific = FALSE)) +
        labs(y =  ytit, x = "Datum"),
      width = 30,
      height = 15,
      units = "cm"
    )
  )
