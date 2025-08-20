# read in data for single treatment plants
plot_data <- read_tsv(here(read_data_here, "amelag_einzelstandorte.tsv")) %>%
  # rename RSV A/B to avoid problems when saving data
  mutate(typ = ifelse(typ == "RSV A/B", "RSV AB", typ)) %>%
  filter(!is.na(!!sym(viruslast_untersucht))) %>%
  # create week variable
  mutate(woche = as.Date(cut(datum, "week"))) %>%
  group_by(typ, woche) %>%
  # count number of observations and share of observations
  # below limit of quantification per virus and week
  count(unter_bg) %>%
  mutate(proportion = n / sum(n)) %>%
  mutate(unter_bg = factor((unter_bg == "ja") * 1, levels = c("1", "0"))) %>%
  ungroup() %>%
  # show only most recent 14 months (roundabout)
  group_by(typ) %>%
  filter(woche >= max(woche) - 425) %>%
  ungroup()

# loop through virus types and make plots for each of them
for (vir in unique(plot_data$typ)) {
  # use self-defined functions to generate plots
  loq_plot(plot_data = plot_data, virus = vir)
}
