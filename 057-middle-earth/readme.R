rm(list = ls())
library(dplyr)
library(maptools)
library(highcharter)
library(geojsonio)
library(rmapshaper)
library(ggplot2)
options(highcharter.debug = TRUE)

fldr <- "D:/Users/joshua.kunst/Downloads/ME-GIS-master/ME-GIS-master"

getdata <- function(file = "Coastline2.shp", k = 0.5) {
  d <- readShapeSpatial(file.path(fldr, file))
  d <- ms_simplify(d, keep = k)
  d <- geojson_list(d)
  d
}
  
cstln <- getdata("Coastline2.shp", .75)
rvers <- getdata("Rivers19.shp", .05)
frsts <- getdata("Forests.shp", 0.90)
lakes <- getdata("Lakes2.shp", 0.2)

cties <- readShapeSpatial(file.path(fldr, "Cities.shp"))
cties <- geojson_json(cties)
  
  
highchart(type = "map") %>% 
  hc_chart(style = list(fontFamily = "Macondo")) %>% 
  hc_title(text = "Middle Earth") %>% 
  hc_add_series(data = cstln, type = "mapline", color = "brown", name = "Coast") %>% 
  hc_add_series(data = rvers, type = "mapline", color = "skyblue", name = "Rivers") %>% 
  hc_add_series(data = frsts, type = "map", color = "green", name = "Forests") %>% 
  hc_add_series(data = frsts, type = "map", color = "skyblue", name = "Lakes") %>% 
  hc_add_series(data = cties, type = "mappoint", color = "skyblue", name = "Cities")
