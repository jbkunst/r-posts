#' ---
#' title: "Wheather chart a la Tufte"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")

#'
library(tidyverse)
library(highcharter)
library(lubridate)
library(stringr)

#' # Data
url_base <- "http://graphics8.nytimes.com/newsgraphics/2016/01/01/weather/assets"
file <- "new-york_ny.csv" # "san-francisco_ca.csv"
url_file <- file.path(url_base, file)

data <- read_csv(url_file)
head(data)

data <- data %>% 
  mutate(x = datetime_to_timestamp(date))

options(highcharter.theme = hc_theme_smpl())


#' # Chart
#' 

# preparing axis
axis <- create_yaxis(2, c(3,1),
                     turnopposite = FALSE,
                     showLastLabel = FALSE,
                     startOnTick = FALSE)

axis[[1]]$title <- list(text = "Temperature")
axis[[2]]$title <- list(text = "Precipitation")

#' setup
hc <- highchart() %>%
  # axis setup
  hc_xAxis(type = "datetime",
           dateTimeLabelFormats = list(month = "%B"),
           showLastLabel = FALSE) %>% 
  hc_yAxis_multiples(axis) %>% 
  # setting tooltip
  hc_tooltip(shared = TRUE,
             seHTML = TRUE,
             headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))) %>% 
  hc_plotOptions(series = list(borderWidth = 0, pointWidth = 4))


#' first data
hc <- hc %>% 
  hc_add_series(data = select(data, x, low = temp_rec_min, high = temp_rec_max),
              type = "columnrange", name = "Record", color = "#ECEBE3", yAxis = 0) %>% 
  hc_add_series(data = select(data, x, low = temp_avg_min, high = temp_avg_max),
                type = "columnrange", name = "Normal", color = "#C8B8B9", yAxis = 0) %>% 
  hc_add_series(data = select(data, x, low = temp_min, high = temp_max),
                type = "columnrange", name = "Observed", color = "#A90048", yAxis = 0) 

#' first data
serieprecip <- data %>% 
  group_by(month) %>% 
  # get the data
  do(data = list_parse(select(., x, y = precip_value))) %>% 
  # additional parameter to the series
  mutate(id = ifelse(month == 1, "precip", NA),
         linkedTo = ifelse(month != 1, "precip", NA),
         yAxis = 1, 
         type = "area",
         name = "Precipitation",
         color = "skyblue") 

head(serieprecip)
glimpse(serieprecip)

hc <- hc %>% 
  hc_add_series_list(list_parse(serieprecip))


#' Add title
library(stringr)

city <- file %>% 
  str_extract(".*_") %>% 
  str_replace_all("_", "") %>% 
  str_replace_all("-", " ") %>%
  str_to_title()

state <- file %>% 
  str_extract("_.*") %>% 
  str_replace_all("_|\\.csv", "") %>% 
  str_to_upper()

title <- paste0(city, ", ", state)

hc <- hc %>% 
  hc_title(text = title)

#' Volia
hc
