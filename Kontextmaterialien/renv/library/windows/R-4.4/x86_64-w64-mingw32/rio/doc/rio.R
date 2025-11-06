## ----include = FALSE----------------------------------------------------------
suppressPackageStartupMessages(library(data.table))

## ----featuretable, echo = FALSE-----------------------------------------------
rf <- data.table(rio:::rio_formats)[!input %in% c(",", ";", "|", "\\t") & type %in% c("import", "suggest", "archive"),]
short_rf <- rf[, paste(input, collapse = " / "), by = format_name]
type_rf <- unique(rf[,c("format_name", "type", "import_function", "export_function", "note")])

feature_table <- short_rf[type_rf, on = .(format_name)]

colnames(feature_table)[2] <- "signature"

setorder(feature_table, "type", "format_name")
feature_table$import_function <- stringi::stri_extract_first(feature_table$import_function, regex = "[a-zA-Z0-9\\.]+")
feature_table$import_function[is.na(feature_table$import_function)] <- ""
feature_table$export_function <- stringi::stri_extract_first(feature_table$export_function, regex = "[a-zA-Z0-9\\.]+")
feature_table$export_function[is.na(feature_table$export_function)] <- ""

feature_table$type <- ifelse(feature_table$type == "suggest", "Suggest", "Default")
feature_table <- feature_table[,c("format_name", "signature", "import_function", "export_function", "type", "note")]

colnames(feature_table) <- c("Name", "Extensions / \"format\"", "Import Package", "Export Package", "Type", "Note")
knitr::kable(feature_table)

## ----echo=FALSE, results='hide'-----------------------------------------------
library("rio")

export(mtcars, "mtcars.csv")
export(mtcars, "mtcars.dta")
export(mtcars, "mtcars_noext", format = "csv")

## -----------------------------------------------------------------------------
library("rio")

x <- import("mtcars.csv")
y <- import("mtcars.dta")

# confirm identical
all.equal(x, y, check.attributes = FALSE)

## -----------------------------------------------------------------------------
head(import("mtcars_noext", format = "csv"))

## ----echo=FALSE, results='hide'-----------------------------------------------
unlink("mtcars.csv")
unlink("mtcars.dta")
unlink("mtcars_noext")

## -----------------------------------------------------------------------------
library("rio")

export(mtcars, "mtcars.csv")
export(mtcars, "mtcars.dta")

## -----------------------------------------------------------------------------
library("magrittr")
mtcars %>%
  subset(hp > 100) %>%
  aggregate(. ~ cyl + am, data = ., FUN = mean) %>%
  export(file = "mtcars2.dta")

## -----------------------------------------------------------------------------
# export to sheets of an Excel workbook
export(list(mtcars = mtcars, iris = iris), "multi.xlsx")

## -----------------------------------------------------------------------------
export_list(list(mtcars = mtcars, iris = iris), "%s.tsv")

## -----------------------------------------------------------------------------
# create file to convert
export(mtcars, "mtcars.dta")

# convert Stata to SPSS
convert("mtcars.dta", "mtcars.sav")

## -----------------------------------------------------------------------------
# create an ambiguous file
fwf <- tempfile(fileext = ".fwf")
cat(file = fwf, "123456", "987654", sep = "\n")

# see two ways to read in the file
identical(import(fwf, widths = c(1, 2, 3)), import(fwf, widths = c(1, -2, 3)))

# convert to CSV
convert(fwf, "fwf.csv", in_opts = list(widths = c(1, 2, 3)))
import("fwf.csv") # check conversion

## ----echo=FALSE, results='hide'-----------------------------------------------
unlink("mtcars.dta")
unlink("mtcars.sav")
unlink("fwf.csv")
unlink(fwf)

## ----echo=FALSE, results='hide'-----------------------------------------------
unlink("mtcars.csv")
unlink("mtcars.dta")
unlink("multi.xlsx")
unlink("mtcars2.dta")
unlink("mtcars.tsv")
unlink("iris.tsv")

