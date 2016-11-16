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
file <- "san-francisco_ca.csv"

url_file <- file.path(url_base, file)

data <- read_csv(url_file)

head(data)

data <- data %>% 
  mutate(x = datetime_to_timestamp(date))

options(highcharter.theme = hc_theme_smpl())

#' # Chart
hc <- highchart() %>%
  # axis setup
  hc_xAxis(type = "datetime", dateTimeLabelFormats = list(month = "%B")) %>% 
  # data
  hc_add_series(data = data %>% select(x, low = temp_rec_min, high = temp_rec_max),
                type = "columnrange", name = "Record", color = "#ECEBE3") %>% 
  hc_add_series(data = data %>% select(x, low = temp_avg_min, high = temp_avg_max),
                   type = "columnrange", name = "Normal", color = "#C8B8B9") %>% 
  hc_add_series(data = data %>% select(x, low = temp_min, high = temp_max),
                   type = "columnrange", name = "Observed", color = "#A90048") %>% 
  # remove legend
  hc_legend(enabled = FALSE) %>% 
  # setting tooltip
  hc_tooltip(
    shared = TRUE,
    useHTML = TRUE,
    headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))
  ) 

hc

hc2 <- hchart(data, "line", x = date, y = precip_value, group = month) %>% 
  hc_xAxis(type = "datetime", dateTimeLabelFormats = list(month = "%B")) %>% 
  hc_legend(enabled = FALSE) %>% 
  hc_colors("skyblue") %>% 
  hc_size(height = 150)
  
hc2

hw_grid(hc, hc2, ncol = 1) %>% 
  htmltools::browsable()
  
  
  