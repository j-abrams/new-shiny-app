



#renv::install("shiny")
#renv::install("shinydashboard")
#renv::install("shinyWidgets")
#renv::install("dplyr")
#renv::install("lubridate")
#renv::install("here")

#renv::install("shinyjs")
#renv::install("rhandsontable")

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

#library(shinycssloaders)
#library(shinyjs)


#renv::install("powerjoin")
library(powerjoin)


source(here("raw_data.R"))

launch_time <- format(Sys.time(), tz="Europe/London")

forecast_start_date <- "2022-05-01"

'%!in%' <- function(x,y)!('%in%'(x,y))



sitting_days_lookup <- read_xlsx(here("Input data/monthly_share.xlsx"), sheet = "lookup")
sitting_days_total <- read_xlsx(here("Input data/monthly_share.xlsx"), sheet = "sitting_days")
sitting_days_df <- read_xlsx(here("Input data/monthly_share.xlsx"), sheet = "monthly_share")

sd_join <- sitting_days_lookup %>%
  dplyr::rename("Period" = "Lookup") %>%
  
  left_join(sitting_days_df, by = "Month") %>%
  filter(Month >= forecast_start_date)
  




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


last_outstanding_val <- jdata_new$OutstandingCases[nrow(jdata_new)]

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



