## ---- fig.width=7-------------------------------------------------------------
library(padr)
coffee

## ---- fig.width=7, message = FALSE--------------------------------------------
library(ggplot2); library(dplyr)

coffee %>% 
  thicken('day') %>% 
  group_by(time_stamp_day) %>%
  summarise(day_amount = sum(amount)) %>% 
  pad() %>% 
  fill_by_value() %>% 
  ggplot(aes(time_stamp_day, day_amount)) + geom_line()

## -----------------------------------------------------------------------------
coffee2 <- coffee %>% thicken('day')
coffee2$time_stamp %>% get_interval()
coffee2$time_stamp_day %>% get_interval()

## -----------------------------------------------------------------------------
to_thicken <- data.frame(day_var = as.Date(c('2016-08-12', '2016-08-13', 
                                              '2016-08-26', '2016-08-29')))
to_thicken %>% thicken(interval = "week")
to_thicken %>% thicken(interval = "4 days")

## -----------------------------------------------------------------------------
head(emergency)

## -----------------------------------------------------------------------------
emergency %>% filter(title == 'EMS: OVERDOSE') %>% 
  thicken('day', 
          start_val = as.POSIXct('2015-12-11 08:00:00', tz = 'EST'),
          colname = 'daystart') %>% 
  group_by(daystart) %>% 
  summarise(nr_od = n()) %>% 
  head()

## -----------------------------------------------------------------------------
account <- data.frame(day     = as.Date(c('2016-10-21', '2016-10-23', '2016-10-26')),
                      balance = c(304.46, 414.76, 378.98))
account %>% pad()

## -----------------------------------------------------------------------------
account %>% pad() %>% tidyr::fill(balance)

## -----------------------------------------------------------------------------
account %>% pad('hour', start_val = as.POSIXct('2016-10-20 22:00:00')) %>% head()

## -----------------------------------------------------------------------------
grouping_df <- data.frame(
  group = rep(c("A", "B"), c(3, 3)),
  date  = as.Date(c("2017-10-02", "2017-10-04", "2017-10-06", "2017-10-01", 
                    "2017-10-03", "2017-10-04")),
  value = rep(2, 6)
)
grouping_df %>% 
  pad(group = "group")

## -----------------------------------------------------------------------------
grouping_df %>% 
  group_by(group) %>% 
  do(pad(.))

## -----------------------------------------------------------------------------
counts <- data.frame(x = as.Date(c('2016-11-21', '2016-11-23',  '2016-11-24')),
                     y = c(2, 4, 4)) %>% pad

counts %>% fill_by_value()
counts %>% fill_by_value(value = 42)
counts %>% fill_by_function(fun = mean)
counts %>% fill_by_prevalent()

## ---- fig.width=7-------------------------------------------------------------
emergency %>% 
  thicken("hour", "h") %>% 
  count(h) %>% 
  slice(1:24) %>% 
  mutate(h_center = center_interval(h)) %>% 
  ggplot(aes(h_center, n)) + geom_bar(stat = "identity")

## ---- message=FALSE-----------------------------------------------------------
emergency %>% 
  filter(title == "EMS: HEAD INJURY") %>% 
  thicken("6 hour", "hour6") %>% 
  count(hour6) %>% 
  pad() %>% 
  fill_by_value() %>% 
  mutate(hour6_fmt = 
           format_interval(hour6, start_format = "%Hh", sep = "-")) %>% 
  ggplot(aes(hour6_fmt, n)) +
  geom_boxplot()

