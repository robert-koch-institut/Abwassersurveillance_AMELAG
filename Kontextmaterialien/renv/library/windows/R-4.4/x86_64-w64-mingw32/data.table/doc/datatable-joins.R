## ----echo = FALSE, message = FALSE----------------------------------------------------------------
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE
)

## -------------------------------------------------------------------------------------------------
Products = data.table(
  id = c(1:4,
         NA_integer_),
  name = c("banana",
           "carrots",
           "popcorn",
           "soda",
           "toothpaste"),
  price = c(0.63,
            0.89,
            2.99,
            1.49,
            2.99),
  unit = c("unit",
           "lb",
           "unit",
           "ounce",
           "unit"),
  type = c(rep("natural", 2L),
           rep("processed", 3L))
)

Products

## -------------------------------------------------------------------------------------------------
NewTax = data.table(
  unit = c("unit","ounce"),
  type = "processed",
  tax_prop = c(0.65, 0.20)
)

NewTax

## -------------------------------------------------------------------------------------------------
set.seed(2156)

ProductReceived = data.table(
  id = 1:10,
  date = seq(from = as.IDate("2024-01-08"), length.out = 10L, by = "week"),
  product_id = sample(c(NA_integer_, 1:3, 6L), size = 10L, replace = TRUE),
  count = sample(c(50L, 100L, 150L), size = 10L, replace = TRUE)
)

ProductReceived

## -------------------------------------------------------------------------------------------------
sample_date = function(from, to, size, ...){
  all_days = seq(from = from, to = to, by = "day")
  weekdays = all_days[wday(all_days) %in% 2:6]
  days_sample = sample(weekdays, size, ...)
  days_sample_desc = sort(days_sample)
  days_sample_desc
}

set.seed(5415)

ProductSales = data.table(
  id = 1:10,
  date = ProductReceived[, sample_date(min(date), max(date), 10L)],
  product_id = sample(c(1:3, 7L), size = 10L, replace = TRUE),
  count = sample(c(50L, 100L, 150L), size = 10L, replace = TRUE)
)


ProductSales

## -------------------------------------------------------------------------------------------------
Products[ProductReceived,
         on = c(id = "product_id")]

## ----eval=FALSE-----------------------------------------------------------------------------------
# Products[ProductReceived,
#          on = list(id = product_id)]

## ----eval=FALSE-----------------------------------------------------------------------------------
# Products[ProductReceived,
#          on = .(id = product_id)]

## -------------------------------------------------------------------------------------------------
ProductsChangedName = setnames(copy(Products), "id", "product_id")
ProductsChangedName

ProductsChangedName[ProductReceived, on = .NATURAL]

## -------------------------------------------------------------------------------------------------
ProductsKeyed = setkey(copy(Products), id)
key(ProductsKeyed)

ProductReceivedKeyed = setkey(copy(ProductReceived), product_id)
key(ProductReceivedKeyed)

ProductsKeyed[ProductReceivedKeyed]

## -------------------------------------------------------------------------------------------------
Products[
  ProductReceived,
  on = c("id" = "product_id"),
  j = .(product_id = x.id,
        name = x.name,
        price,
        received_id = i.id,
        date = i.date,
        count,
        total_value = price * count)
]

## -------------------------------------------------------------------------------------------------
dt1 = ProductReceived[
  Products,
  on = c("product_id" = "id"),
  by = .EACHI,
  j = .(total_value_received  = sum(price * count))
]


dt2 = ProductReceived[
  Products,
  on = c("product_id" = "id"),
][, .(total_value_received  = sum(price * count)),
  by = "product_id"
]

identical(dt1, dt2)

## -------------------------------------------------------------------------------------------------
NewTax[Products, on = c("unit", "type")]

## -------------------------------------------------------------------------------------------------
# First Table
Products[ProductReceived,
         on = c("id" = "product_id"),
         nomatch = NULL]

# Second Table
ProductReceived[Products,
                on = .(product_id = id),
                nomatch = NULL]

## -------------------------------------------------------------------------------------------------
Products[!ProductReceived,
         on = c("id" = "product_id")]

## -------------------------------------------------------------------------------------------------
ProductReceived[!Products,
                on = c("product_id" = "id")]

## -------------------------------------------------------------------------------------------------
SubSetRows = Products[
  ProductReceived,
  on = .(id = product_id),
  nomatch = NULL,
  which = TRUE
]

SubSetRows

## -------------------------------------------------------------------------------------------------
SubSetRowsSorted = sort(unique(SubSetRows))

SubSetRowsSorted

## -------------------------------------------------------------------------------------------------
Products[SubSetRowsSorted]

## -------------------------------------------------------------------------------------------------
ProductReceived[Products,
                on = list(product_id = id)]

## -------------------------------------------------------------------------------------------------
NewTax[Products,
       on = c("unit", "type")
][, ProductReceived[.SD,
                    on = list(product_id = id)],
  .SDcols = !c("unit", "type")]

## -------------------------------------------------------------------------------------------------
ProductReceived[product_id == 1L]

## -------------------------------------------------------------------------------------------------
ProductSales[product_id == 1L]

## -------------------------------------------------------------------------------------------------
ProductReceived[ProductSales[list(1L),
                             on = "product_id",
                             nomatch = NULL],
                on = "product_id",
                allow.cartesian = TRUE]

## -------------------------------------------------------------------------------------------------
ProductReceived[ProductSales,
                on = "product_id",
                allow.cartesian = TRUE]

## -------------------------------------------------------------------------------------------------
ProductReceived[ProductSales[product_id == 1L],
                on = .(product_id),
                allow.cartesian = TRUE,
                mult = "first"]

## -------------------------------------------------------------------------------------------------
ProductReceived[ProductSales[product_id == 1L],
                on = .(product_id),
                allow.cartesian = TRUE,
                mult = "last"]

## -------------------------------------------------------------------------------------------------
ProductsTempId = copy(Products)[, temp_id := 1L]

## -------------------------------------------------------------------------------------------------
AllProductsMix =
  ProductsTempId[ProductsTempId,
                 on = "temp_id",
                 allow.cartesian = TRUE]

AllProductsMix[, temp_id := NULL]

# Removing type to make easier to see the result when printing the table
AllProductsMix[, !c("type", "i.type")]

## -------------------------------------------------------------------------------------------------
merge(x = Products,
      y = ProductReceived,
      by.x = "id",
      by.y = "product_id",
      all = TRUE,
      sort = FALSE)

## -------------------------------------------------------------------------------------------------
ProductSalesProd2 = ProductSales[product_id == 2L]
ProductReceivedProd2 = ProductReceived[product_id == 2L]

## -------------------------------------------------------------------------------------------------
ProductReceivedProd2[ProductSalesProd2,
                     on = "product_id",
                     allow.cartesian = TRUE
][date < i.date]

## -------------------------------------------------------------------------------------------------
ProductReceivedProd2[ProductSalesProd2,
                     on = list(product_id, date < date)]

## -------------------------------------------------------------------------------------------------
ProductReceivedProd2[ProductSalesProd2,
                     on = list(product_id, date < date),
                     nomatch = NULL]

## -------------------------------------------------------------------------------------------------
ProductPriceHistory = data.table(
  product_id = rep(1:2, each = 3),
  date = rep(as.IDate(c("2024-01-01", "2024-02-01", "2024-03-01")), 2),
  price = c(0.59, 0.63, 0.65,  # Banana prices
            0.79, 0.89, 0.99)  # Carrot prices
)

ProductPriceHistory

## -------------------------------------------------------------------------------------------------
ProductPriceHistory[ProductSales,
                    on = .(product_id, date),
                    roll = TRUE,
                    j = .(product_id, date, count, price)]

## -------------------------------------------------------------------------------------------------
ProductPriceHistory[ProductSales,
                    on = .(product_id, date),
                    roll = TRUE,
                    nomatch = NULL,
                    j = .(product_id, date, count, price)]

## -------------------------------------------------------------------------------------------------
ProductReceived[list(c(1L, 3L), 100L),
                on = c("product_id", "count")]

## -------------------------------------------------------------------------------------------------
ProductReceived[list(c(1L, 3L), 100L),
                on = c("product_id", "count"),
                nomatch = NULL]

## -------------------------------------------------------------------------------------------------
ProductReceived[!list(c(1L, 3L), 100L),
                on = c("product_id", "count")]

## -------------------------------------------------------------------------------------------------
Products[c("banana","popcorn"),
         on = "name",
         nomatch = NULL]

Products[!"popcorn",
         on = "name"]


## -------------------------------------------------------------------------------------------------
copy(Products)[ProductPriceHistory,
               on = .(id = product_id),
               j = `:=`(price = tail(i.price, 1),
                        last_updated = tail(i.date, 1)),
               by = .EACHI][]

