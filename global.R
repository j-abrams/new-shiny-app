



#renv::install("shiny")
#renv::install("shinydashboard")
#renv::install("shinyWidgets")
#renv::install("dplyr")
#renv::install("lubridate")
#renv::install("here")

#renv::install("shinyjs")

library(dplyr)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(lubridate)
library(here)
library(shinyjs)

library(plotly)
library(ggplot2)

library(fontawesome)

#library(shinycssloaders)
#library(shinyjs)


source(here("raw_data.R"))

launch_time <- format(Sys.time(), tz="Europe/London")

forecast_start_date <- "2022-05-01"

'%!in%' <- function(x,y)!('%in%'(x,y))




# jdata <- read.csv("Input data/jdata2.csv") %>%
#   mutate(Date = paste0("01-", Date)) %>%
#   mutate(Date = as.Date(Date, format = "%d-%b-%y")) %>%
#   # Add flag to distinguish between actuals and projections
#   mutate(Actuals = "Projection") %>%
#   filter(Date %!in% ImmigrationData$Date ) %>%
#   select(Date, Receipts, Disposals, OutstandingCases, Actuals)


jdata_new <- ImmigrationData %>%
  mutate(Actuals = ifelse(Date < forecast_start_date, 
                          "Actual", "Projection"),
         Date = as.Date(Date)) %>%
  dplyr::rename("Receipts" = "IA_RECEIPTS",
                "Disposals" = "IA_DISPOSALS",
                "OutstandingCases" = "IA_OUTSTANDING") %>%
  #bind_rows(jdata) %>%
  arrange(Date)


last_outstanding_val <- jdata_new$OutstandingCases[nrow(jdata_new)]








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



