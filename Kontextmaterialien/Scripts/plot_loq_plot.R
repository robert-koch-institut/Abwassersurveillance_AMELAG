# Read only required columns
cols <- c(
  "standort", "typ", "datum", "unter_bg",
  viruslast_untersucht
)

plot_data <- read_tsv(
  here(read_data_here, "amelag_einzelstandorte.tsv"),
  col_select = all_of(cols),
  show_col_types = FALSE
) %>%
  mutate(
    typ = if_else(typ == "RSV A/B", "RSV AB", typ)
  ) %>%
  filter(!is.na(.data[[viruslast_untersucht]])) %>%
  
  # Exclude observations within discard periods
  anti_join(
    discard_rules %>%
      mutate(
        entfernt_bis = coalesce(entfernt_bis, Sys.Date())
      ),
    by = join_by(
      standort,
      typ,
      between(datum, entfernt_vom, entfernt_bis)
    )
  ) %>%
  
  # Thursday-to-Wednesday reporting week
  mutate(
    woche = as.Date(datum) +
      ((3 - lubridate::wday(datum, week_start = 1)) %% 7)
  ) %>%
  
  # Filter before aggregation
  group_by(typ) %>%
  filter(woche >= max(woche) - 425) %>%
  ungroup() %>%
  
  # Count unique sites with at least one positive sample
  group_by(typ, woche) %>%
  summarise(
    n_total = n_distinct(standort),
    unter_bg = n_distinct(
      standort[unter_bg %in% "nein"]
    ),
    .groups = "drop"
  ) %>%
  arrange(typ, woche)

# loop through virus types and make plots for each of them
for (vir in unique(plot_data$typ)) {
  # use self-defined functions to generate plots
  loq_plot(plot_data = plot_data, virus = vir)
}
