# Use the newly estimated period-specific GAMs from aggregation_calculation.R.
# Do not re-read amelag_aggregierte_kurve.tsv here: the published file may
# contain predictions from the previous, continuous-curve method.
if (!exists("df_agg", inherits = TRUE) ||
    !"estimation_period" %in% names(df_agg)) {
  stop("Run aggregation_calculation.R before plot_aggregated_curve.R ",
       "to compute the period-specific aggregated GAM predictions.")
}

data_plots <- df_agg %>%
  arrange(typ, datum)

# Should log data be shown?
if (show_log_data) {
  data_plots <- data_plots %>%
    mutate(across(all_of(c("vorhersage", "untere_schranke", "obere_schranke",
                           viruslast_untersucht)), ~ log10(.x)))
  ytit <- expression(atop("Viruslast im Abwasser", atop(paste(
    "in ", log[10], " Genkopien / Liter"
  ))))
  filename_add <- "_log"
} else {
  ytit <- expression(atop("Viruslast im Abwasser", atop(paste(
    "in Genkopien / Liter"
  ))))
  filename_add <- ""
}

# The estimation_period aesthetic prevents ribbons and curves being connected
# across long observation gaps. Keep NA measurement rows in the input; display
# observed points also when their period has fewer than min_obs measurements.
data_plots %>%
  group_by(typ) %>%
  group_map(
    ~ ggsave(
      here(
        results_here,
        .y$typ,
        paste0("aggregierte_Kurve", filename_add, ".pdf")
      ),
      ggplot(data = .x, aes(x = datum)) +
        geom_ribbon(
          data = .x %>%
            filter(!is.na(estimation_period),
                   is.finite(untere_schranke), is.finite(obere_schranke)),
          aes(ymin = untere_schranke, ymax = obere_schranke,
              group = estimation_period),
          fill = "lightblue"
        ) +
        geom_point(aes(y = !!sym(viruslast_untersucht)),
                   colour = "grey", na.rm = TRUE) +
        geom_line(
          data = .x %>%
            filter(!is.na(estimation_period), is.finite(vorhersage)),
          aes(y = vorhersage, group = estimation_period),
          linewidth = 1
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45)) +
        scale_x_date(date_breaks = "month", date_labels = "%b %y") +
        scale_y_continuous(labels = ~ format(.x, scientific = FALSE)) +
        labs(y = ytit, x = "Datum"),
      width = 30,
      height = 15,
      units = "cm"
    )
  )

