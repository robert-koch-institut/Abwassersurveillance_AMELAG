# read in data for single treatment plants
data_combined <- read_tsv(here(read_data_here,
                               "amelag_einzelstandorte.tsv"))

# heatmap
plot_data <- data_combined %>%
  # remove NAs at the beginning of each series
  filter(trend != "keine Daten vorhanden") %>%
  # add week and day
  mutate(woche = as.Date(cut(datum, "week")),
         tag = wday(datum, week_start = 1)) %>%
  # determine starting date of heatmap - show only the last four months
  filter(woche >= (max(woche, na.rm = TRUE) %m-% months(4))) %>%
  # count Wednesday values per week (zero values could occur for most current week
  # if there are only measurements on Monday e.g.)
  group_by(woche, tag) %>%
  mutate(wedn_val = sum(tag == 3)) %>%
  ungroup() %>%
  # drop weeks without Wednesday values
  group_by(woche) %>%
  filter(!all(wedn_val == 0)) %>%
  ungroup() %>%
  # add NAs for intermediate series
  complete(standort, woche, tag) %>%
  # but drop NAs for Thursdays and following days in the last week
  mutate(last_week_days_after_wedn = ifelse(woche == max(woche) &
                                              tag > 3, 1, 0)) %>%
  filter(last_week_days_after_wedn != 1) %>%
  # but fill in bundesland for creating full bundesland-Standort variable below
  group_by(standort) %>%
  fill(bundesland, .direction = "updown") %>%
  ungroup() %>%
  # add asterisk to EU-funded places
  # mutate(Standort = ifelse(esi == 1, paste0(Standort, "*"), Standort)) %>%
  group_by(woche, standort) %>%
  # take only Wednesday values
  filter(tag == 3) %>%
  ungroup() %>%
  mutate(trend = ifelse(is.na(trend), "keine Daten vorhanden", trend)) %>%
  # change variable to factor for better visualization
  mutate(trend = as.factor(trend)) %>%
  arrange(bundesland, standort) %>%
  mutate(standort = str_replace(standort, "_", " ")) %>%
  # create new name variable
  mutate(BL_Standort = paste(bundesland, "-", standort))

# generate heatmap
heatmap <- plot_data %>%
  ggplot(aes(woche, BL_Standort)) +
  geom_tile(aes(fill = trend), colour = "white") +
  scale_fill_manual(
    values = c("#eac66c",
               "#ce7b47",
               "#9a333d",
               "gray90"),
    name = "Trend",
    breaks = c("Fallend", "Unverändert", "Ansteigend", "keine Daten vorhanden"),
    labels = c("Fallend",
               "Unverändert",
               "Ansteigend",
               "keine Daten vorhanden")
  ) +
  labs(x = "Kalenderwoche", y = "") +
  theme_classic() +
  theme(legend.position = "bottom") +
  scale_y_discrete(limits = rev, expand = c(0, 0)) +
  scale_x_date(date_labels = "%W \n%Y",
               date_breaks = "1 week",
               expand = c(0, 0))
heatmap

# save heatmap
ggsave(
  here(results_here, paste0("heatmap.pdf")),
  plot = heatmap,
  width = 30,
  height = 25,
  units = "cm"
)
