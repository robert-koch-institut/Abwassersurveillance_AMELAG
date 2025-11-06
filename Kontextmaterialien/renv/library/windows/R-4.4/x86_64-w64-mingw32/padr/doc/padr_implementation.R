## ---- message = FALSE, warning= FALSE-----------------------------------------
start_val <- as.POSIXct('2016-03-25 08:15:00', tz = 'CET')
seq(start_val, by = 'day', length.out = 4) 
seq(start_val, by = 'DSTdays', length.out = 4)

## -----------------------------------------------------------------------------
seq(start_val, by = 'week', length.out = 2)

## -----------------------------------------------------------------------------
seq(start_val, by = '7 DSTdays', length.out = 2)

## -----------------------------------------------------------------------------
library(padr)
to_pad <- data.frame(dt = seq(as.POSIXct('2016-02-02 14:53:12', tz = 'CET'),
                                         length.out = 2, by = 'day'))
pad(to_pad, start_val = as.POSIXct('2016-02-01 14:53:12', tz = 'EST'))

