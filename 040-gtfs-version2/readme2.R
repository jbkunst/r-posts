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
knitr::opts_chunk$set(message = FALSE, warning = FALSE)
library("dplyr")
library("readr")
library("ggplot2")
library("stringr")
library("purrr")
library("highcharter")

#'
#' ![](http://www.transitwiki.org/TransitWiki/images/f/ff/GTFS_data_model_diagram.PNG)


#'
#' Read data
#' 
#' 
dir()

urlbase <- "http://transitfeeds-data.s3-us-west-1.amazonaws.com/public/feeds/sfmta/351/20160216/original" # sf
# urlbase <- "http://transitfeeds-data.s3-us-west-1.amazonaws.com/public/feeds/mta/79/20151207/original"
# urlbase <- "http://transitfeeds-data.s3-us-west-1.amazonaws.com/public/feeds/transport-for-greater-manchester/224/20160331/original"

dfroutes <- read_csv(file.path(urlbase, "routes.txt"))
dfroutes

dfshapes <- read_csv(file.path(urlbase, "shapes.txt"))
dfroutes

dfstops <- read_csv(file.path(urlbase, "stops.txt"))
dfstops

dfshapes %>% count(shape_id) %>% arrange(desc(n))



ggplot() + 
  geom_path(data = dfshapes, aes(shape_pt_lon, shape_pt_lat, group = shape_id, color = shape_id)) +
  # geom_point(data = dfstops, aes(stop_lon,  stop_lat), color = "gray") +
  coord_equal() + 
  theme(legend.position = "none")


hc <- highchart()

for (shp in unique(dfshapes$shape_id)) {
  dfshapeaux <- dfshapes %>%
    filter(shape_id == shp) %>% 
    select(shape_pt_lon, shape_pt_lat) %>% 
    list.parse2()
  
  hc <- hc %>% hc_add_series(data = )
}


