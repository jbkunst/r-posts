library(dplyr)
library(maptools)
library(highcharter)
library(geojsonio)
library(rmapshaper)
library(readr)
library(viridis)
options(highcharter.debug = TRUE)


folder <- "~/../Downloads/thematic-maps-ggplot2-master/thematic-maps-ggplot2-master/"

map <- readShapeSpatial(file.path(folder, "input/geodata/gde-1-1-15.shp"))
map <- ms_simplify(map, keep = 1) # because ms_simplify fix the ü's
map <- geojson_list(map)

str(map, max.level = 1)

str(map$features[[7]], max.level = 5)

data <- read_csv(file.path(folder, "input/avg_age_15.csv")) 
data <- select(data, -X1)
data <- rename(data, value = avg_age_15)
data  

quantile(data$avg_age_15)

options(highcharter.debug = TRUE, highcharter.verbose = TRUE)


# http://jsfiddle.net/gh/get/jquery/2/highcharts/highcharts/tree/master/samples/maps/demo/heatmap/
colors <- rev(magma(8)[2:7])
colors <- gsub("FF$", "", colors)
brks <- c(33, 90, 40, 41, 42, 43, 67)

highchart(type = "map") %>% 
  hc_add_series(mapData = map, data = data, type = "map",
                joinBy = c("BFS_ID", "bfs_id"), value = "value",
                borderWidth = 0) %>% 
  hc_tooltip(pointFormat = "{point.Secondary_}") %>% 
  hc_colorAxis(dataClasses = color_classes(brks, colors)) %>% 
  hc_mapNavigation(enabled = TRUE)

