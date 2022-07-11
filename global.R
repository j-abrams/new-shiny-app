



#renv::install("shiny")
#renv::install("shinydashboard")
#renv::install("shinyWidgets")
#renv::install("dplyr")


library(dplyr)
library(shiny)
library(shinydashboard)
library(shinyWidgets)

#library(lubridate)
#library(shinycssloaders)
#library(shinyjs)


launch_time <- format(Sys.time(), tz="Europe/London")

forecast_start_date <- "2022-02-01"


# import and initial wrangling for computation in the global.R file


jdata <- read.csv("jdata.csv") %>%
  dplyr::rename("Date" = "ï..Date") %>%
  mutate(Date = paste0("01-", Date)) %>%
  mutate(Date = as.Date(Date, format = "%d-%b-%y")) %>%
  filter(Date <= forecast_start_date) %>%
  mutate(Actuals = T)

jdata_new <- read.csv("jdata2.csv") %>%
  mutate(Date = paste0("01-", Date)) %>%
  mutate(Date = as.Date(Date, format = "%d-%b-%y")) %>%
  # Add flag to distinguish between actuals and projections
  mutate(Actuals = F) %>%
  bind_rows(jdata) %>%
  select(-c(Acases, Sdays, Disprate)) %>%
  arrange(Date, desc(Actuals)) %>%
  filter(duplicated(Date) == FALSE)


# +- 10%
# Best case: Low receipts and High disp rate
# Worst case: inverse



