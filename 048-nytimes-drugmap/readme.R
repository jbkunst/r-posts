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

color_stops <- function(n = 10, option = "D") {
  
  data.frame(q = seq(0, n)/n,
             c = substring(viridis(n + 1, option = "D"), 0, 7)) %>% 
    list.parse2()
}
  

data("uscountygeojson")
data("unemployment")

data <-  fromJSON(URL) %>% 
  tbl_df() %>% 
  gather(year, value, -fips) %>% 
  mutate(year = sub("^y", "", year))

count(data, year)
# 
# highchart() %>% 
#   hc_add_series_map(map = uscountygeojson,
#                     df = data %>% filter(year == max(year)) %>% select(fips, value),
#                     value = "value", joinBy = c("fips"),
#                     borderWidth = 0.1) %>% 
#   hc_colorAxis(stops = color_stops()) 


ds <- data %>% 
  group_by(fips) %>% 
  do(item = list(
    fips = first(.$fips),
    sequence = .$value,
    value = first(.$value))) %>% 
  .$item


hc <- highchart(type = "map") %>% 
  hc_add_series(data = ds,
                name = "drug deaths per 100,000",
                mapData = uscountygeojson,
                joinBy = "fips",
                borderWidth = 0.01) %>% 
  hc_colorAxis(stops = color_stops()) %>% 
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
  )

hc


