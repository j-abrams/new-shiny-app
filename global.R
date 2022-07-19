



#renv::install("shiny")
#renv::install("shinydashboard")
#renv::install("shinyWidgets")
#renv::install("dplyr")
#renv::install("lubridate")
#renv::install("here")
#renv::install("shinyjs")
#renv::install("rhandsontable")

#renv::install("reactlog")


#renv::install("rlang")

#renv::install("shinycssloaders")

library(shinycssloaders)

library(rlang)

library(reactlog)

reactlog::reactlog_enable()

#shiny::reactlogReset()
#shiny::reactlogShow()

# Package libraries required
library(dplyr)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(here)
library(shinyjs)
library(ggplot2)
library(fontawesome)
library(rhandsontable)
library(lubridate)
library(plotly)
library(powerjoin)
library(tidyr)



shinyOptions(shiny.fullstacktrace = T)

# Source command to pre-processing script raw_data.R
source(here("raw_data.R"))

# Launch time test
launch_time <- format(Sys.time(), tz="Europe/London")

# First day of projections
forecast_start_date <- "2022-05-01"

'%!in%' <- function(x,y)!('%in%'(x,y))


# read in excel data from the workbook object
sitting_days_lookup <- read_xlsx(here("Input data/monthly_share.xlsx"), sheet = "lookup")
sitting_days_total <- read_xlsx(here("Input data/monthly_share.xlsx"), sheet = "sitting_days")
sitting_days_df <- read_xlsx(here("Input data/monthly_share.xlsx"), sheet = "monthly_share")


# Sitting days lookup and monthly share combined
sd_join <- sitting_days_lookup %>%
  dplyr::rename("Period" = "Lookup") %>%
  left_join(sitting_days_df, by = "Month") %>%
  filter(Month >= forecast_start_date)
  


# ImmigrationData is defined in raw_data.R - jdata_new requires extra handling steps:
# - Flag for actuals projections
# - Renaming variables
# - Creating an empty column, Sitting Days, as a placeholder
jdata_new <- ImmigrationData %>%
  mutate(Actuals = ifelse(Date < forecast_start_date, 
                          "Actual", "Projection"),
         Date = as.Date(Date)) %>%
  dplyr::rename("Receipts" = "IA_RECEIPTS",
                "Disposals" = "IA_DISPOSALS",
                "OutstandingCases" = "IA_OUTSTANDING") %>%
  #bind_rows(jdata) %>%
  arrange(Date) %>%
  mutate(`Sitting Days` = NA) %>%
  select(Date, Receipts, `Sitting Days`, Disposals, OutstandingCases, Actuals)


# Starting point used in calculations for outstanding cases in the future
last_outstanding_val <- jdata_new$OutstandingCases[nrow(jdata_new)]


# didn't work, rip
level_test <- as.factor(c("Actual", "Projection"))






# archive

# import and initial wrangling for computation in the global.R file


# jdata <- read.csv("Input data/jdata.csv") %>%
#   dplyr::rename("Date" = "ï..Date") %>%
#   mutate(Date = paste0("01-", Date)) %>%
#   mutate(Date = as.Date(Date, format = "%d-%b-%y")) %>%
#   filter(Date <= forecast_start_date) %>%
#   mutate(Actuals = "Actual")
# 
# jdata_new <- read.csv("Input data/jdata2.csv") %>%
#   mutate(Date = paste0("01-", Date)) %>%
#   mutate(Date = as.Date(Date, format = "%d-%b-%y")) %>%
#   # Add flag to distinguish between actuals and projections
#   mutate(Actuals = "Projection") %>%
#   bind_rows(jdata) %>%
#   select(-c(Acases, Sdays, Disprate)) %>%
#   arrange(Date, desc(Actuals)) %>%
#   filter(duplicated(Date) == FALSE)


# +- 10%
# Best case: Low receipts and High disp rate
# Worst case: inverse



