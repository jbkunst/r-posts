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

# 
# library(tigris)
# library(ggplot2)
# library(purrr)
# library(tidyr)

# library(sp)
# library(rgeos)
# library(rgdal)
# library(maptools)
# library(ggthemes)
# library(viridis)

library("jsonlite")
library("dplyr")
library("tidyr")
library("highcharter")
library("viridisLite")

#'
#' ## Data
#' 
URL <- "http://graphics8.nytimes.com/newsgraphics/2016/01/15/drug-deaths/c23ba79c9c9599a103a8d60e2329be1a9b7d6994/data.json"

data("uscountygeojson")
data("unemployment")

data <-  fromJSON(URL) %>% 
  tbl_df() %>% 
  gather(year, value, -fips) %>% 
  mutate(year = sub("^y", "", year),
         value = ifelse(is.na(value), 0, value))

ds <- data %>% 
  group_by(fips) %>% 
  do(item = list(
    fips = first(.$fips),
    sequence = .$value,
    value = first(.$value))) %>% 
  .$item

ds[[1]]
uscountygeojson$features[[1]]$properties

hc <- highchart(type = "map") %>% 
  hc_add_series(data = ds,
                name = "drug deaths per 100,000",
                mapData = uscountygeojson,
                joinBy = "fips",
                borderWidth = 0.01) %>% 
  hc_colorAxis(stops = color_stops(option = "A")) %>% 
  hc_motion(
    enabled = TRUE,
    axisLabel = "year",
    labels = sort(unique(data$year)),
    series = 0,
    updateIterval = 50,
    magnet = list(
     round = "floor",
     step = 0.1
    )
  ) %>% 
  hc_title(text = "How the Epidemic of Drug Overdose Deaths Ripples") %>% 
  hc_add_theme(hc_theme_smpl())


hc


