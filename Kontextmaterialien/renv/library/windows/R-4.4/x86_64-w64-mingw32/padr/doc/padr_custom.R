## ---- fig.width = 7, message=FALSE, warning=FALSE-----------------------------
library(padr); library(dplyr); library(ggplot2)
veh_acc <- emergency %>% 
  filter(title == "Traffic: VEHICLE ACCIDENT -",
         lubridate::month(time_stamp) %in% 4:6) 

veh_acc_line_plot <- function(padded_df,
                              units_to_last = NULL) {
  padded_df %>% 
  fill_by_value() %>% 
  thicken("day", "day") %>% 
  mutate(interval = format_interval(day_hour, "%H", sep = "-" , 
                                    units_to_last = units_to_last)) %>% 
  ggplot(aes(day, n)) + 
  facet_wrap(~interval) +
  geom_line() 
}

veh_acc %>%
  thicken("3 hour", "day_hour") %>% 
  count(day_hour) %>% 
  pad() %>% 
  veh_acc_line_plot()

## -----------------------------------------------------------------------------
veh_acc_span <- 
  span_around(veh_acc$time_stamp, interval = "hour", start_shift = "7 hour") %>% 
  subset_span(list(hour = c(7, 10, 16, 19)))

## -----------------------------------------------------------------------------
veh_acc_cust <- veh_acc %>% 
  thicken_cust(spanned = veh_acc_span, colname = "day_hour") %>% 
  count(day_hour) %>% 
  pad_cust(veh_acc_span)

## ---- fig.width=7-------------------------------------------------------------
veh_acc_line_plot(veh_acc_cust, units_to_last = 12 * 3600)

