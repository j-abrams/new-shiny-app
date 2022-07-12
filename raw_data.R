library(tidyverse)
library(readxl)
library(lubridate)

rm(list=ls())

Data1819 <- read.csv("C:\\Users\\GillHolland\\OneDrive - Hartley McMaster Ltd\\HMCTS data\\HMCTS_raw_data_for_Apr18_to_Apr19.csv")

Data1920 <- read.csv("C:\\Users\\GillHolland\\OneDrive - Hartley McMaster Ltd\\HMCTS data\\HMCTS_raw_data_for_Apr19_to_Apr20.csv")

Data2021 <- read.csv("C:\\Users\\GillHolland\\OneDrive - Hartley McMaster Ltd\\HMCTS data\\20210601_HMCTS_raw_data_for_Apr20_to_Apr21.csv")

Data2122 <- read_xlsx("C:\\Users\\GillHolland\\OneDrive - Hartley McMaster Ltd\\HMCTS data\\HMCTS_Management_Information_April_2021_to_April_2022.xlsx")


#Create a date field

Data1819$Date <- as.Date(Data1819$MONTH, format="%d-%b-%y")
Data1920$Date <- as.Date(Data1920$MONTH, format="%d-%b-%y")
Data2021$Date <- as.Date(Data2021$MONTH, format="%d-%b-%y")
Data2122$Date <- as.Date(Data2122$MONTH, format="%d-%b-%y")


#Extract date and immigration data

Data1819 <- select(Data1819, Date, IA_RECEIPTS, IA_DISPOSALS, IA_OUTSTANDING )
Data1920 <- select(Data1920, Date, IA_RECEIPTS, IA_DISPOSALS, IA_OUTSTANDING )
Data2021 <- select(Data2021, Date, IA_RECEIPTS, IA_DISPOSALS, IA_OUTSTANDING )
Data2122 <- select(Data2122, Date, IA_RECEIPTS, IA_DISPOSALS, IA_OUTSTANDING )

#Reduce from 13 to 12 records for each year to remove duplicates
#Not required for latest year
Data1819<- Data1819 %>%
  filter(Date <= "2019-03-31")

Data1920<- Data1920 %>%
  filter(Date <= "2020-03-31")

Data2021<- Data2021 %>%
  filter(Date <= "2021-03-31")


#Join to one table

ImmigrationData <- rbind(Data1819,Data1920, Data2021, Data2122) 


# add month year format e.g. Nov-21
#ImmigrationData$Date <- format(ImmigrationData$Date, format="%b-%y")

ImmigrationData <- ImmigrationData %>%
  mutate(Date = format(Date, format="%b-%y") )


