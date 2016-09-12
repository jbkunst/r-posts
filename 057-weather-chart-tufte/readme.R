#' ---
#' title: ""
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


data <- read_csv("http://academic.udayton.edu/kissock/http/Weather/gsod95-current/CASANFRA.txt",
                 col_names = )

data <- tbl_df(MSP2012) %>%
  mutate(date = str_c("2012", month, day, sep = "-"),
         date = ymd(date))
         
col_to_hex <- function(name = c("wheat", "red")) {
  name %>% 
    col2rgb() %>% 
    t() %>% 
    {./255} %>% 
    rgb()
}

options(highcharter.theme = hc_theme_smpl())

#These color codes will be useful for building your graphics:
colors<-c(background="#e4dcd5", record="#cbc3aa", normal="#9f9786", daily="#763f59", axis="#a59d8b")


highchart() %>%
  hc_xAxis(type = "datetime") %>% 
  hc_add_series_df(data, type = "columnrange", x = date, low = recordLo, high = recordHi, name = "Record") %>% 
  hc_add_series_df(data, type = "columnrange", x = date, low = normalLo, high = normalHi, name = "Normal") %>% 
  hc_add_series_df(data, type = "columnrange", x = date, low = observedLo, high = observedHi, name = "Observed") %>% 
  hc_tooltip(
    shared = TRUE,
    useHTML = TRUE,
    headerFormat = as.character(tags$small("{point.x: %b %d}<br>"))
  ) 
  
  
  