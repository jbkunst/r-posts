rm(list = ls())
library(dplyr)
library(maptools)
library(highcharter)
library(geojsonio)
library(rmapshaper)
options(highcharter.debug = TRUE)

fldr <- "~/ME-GIS-master"

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
  
thm <- hc_theme(
  chart = list(
    style = list(fontFamily = "Macondo"),
    backgroundColor = NULL,
    # backgroundColor = "#F3EABC"
    # divBackgroundImage = "http://www.texturepalace.com/wp-content/uploads/vintage-paper-texture-for-photoshop-3.jpg"
    divBackgroundImage = "https://www.myfreetextures.com/wp-content/uploads/2011/06/another-rough-old-and-worn-parchment-paper.jpg"
  )
)

  
highchart(type = "map") %>% 
  hc_title(text = "Middle Earth") %>% 
  hc_add_series(data = cstln, type = "mapline", color = "brown", name = "Coast") %>%
  hc_add_series(data = rvers, type = "mapline", color = "skyblue", name = "Rivers") %>%
  hc_add_series(data = frsts, type = "map", color = "green", name = "Forests") %>%
  hc_add_series(data = frsts, type = "map", color = "skyblue", name = "Lakes") %>%
  hc_add_series(data = cties, type = "mappoint", color = "black", name = "Cities") %>% 
  hc_add_theme(thm)

