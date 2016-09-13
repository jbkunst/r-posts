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
load(url("http://www.stolaf.edu/people/olaf/cs125/MSP2012.RData"))

data <- tbl_df(MSP2012) %>%
  mutate(date = str_c("2012", month, day, sep = "-"),
         date = ymd(date),
         tmps = datetime_to_timestamp(date))

head(data)
options(highcharter.theme = hc_theme_smpl())

#' # Chart

highchart() %>%
  # details
  hc_chart(backgroundColor = "#E4DCD5") %>% 
  hc_xAxis(type = "datetime", dateTimeLabelFormats = list(month = "%B")) %>% 
  hc_plotOptions(series = list(borderColor = "transparent")) %>% 
  # data
  hc_add_series(data = list_parse(select(data, x = tmps, low = recordLo, high = recordHi)),
                type = "columnrange", name = "Record", color = "#CBC3AA") %>% 
  hc_add_series(data = list_parse(select(data, x = tmps, low = normalLo, high = normalHi)),
                   type = "columnrange", name = "Normal", color = "#9F9786") %>% 
  hc_add_series(data = list_parse(select(data, x = tmps, low = observedLo, high = observedHi)),
                   type = "columnrange", name = "Observed", color = "#543946") %>% 
  hc_tooltip(
    shared = TRUE,
    useHTML = TRUE,
    headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))
  ) 
  
  
  