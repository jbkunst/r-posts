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


no_classes <- 6

colors <- magma(no_classes + 2) %>% 
  rev() %>% 
  head(-1) %>% 
  tail(-1) %>% 
  gsub("FF$", "", .)

brks <- quantile(data$value, probs = seq(0, 1, length.out = no_classes + 1))
brks <- ifelse(1:(no_classes + 1) < no_classes, floor(brks), ceiling(brks))
brks



highchart(type = "map") %>% 
  # data part
  hc_add_series(mapData = map, data = data, type = "map",
                joinBy = c("BFS_ID", "bfs_id"), value = "value",
                borderWidth = 0) %>% 
  hc_colorAxis(dataClasses = color_classes(brks, colors)) %>% 
  # functionality
  hc_tooltip(pointFormat = "{point.Secondary_}") %>% 
  hc_legend(align = "right", verticalAlign = "bottom", layout = "vertical") %>%
  hc_mapNavigation(enabled = TRUE) %>% 
  # style
  hc_chart(backgroundColor = "#f5f5f2") %>% 
  hc_title(text = "Switzerland's regional demographics") %>% 
  hc_subtitle(text = "Average age in Swiss municipalities, 2015") %>% 
  hc_credits(enabled = TRUE,
             text = "Map CC-BY-SA; Author: Timo Grossenbacher (@grssnbchr), Geometries: ThemaKart, BFS; Data: BFS, 2016; Relief: swisstopo, 2016")


library(raster)
# read in background relief
relief <- raster(file.path(folder, "input/geodata/02-relief-georef-clipped-resampled.tif"))
# relief_spdf <- as(relief, "SpatialPolygonsDataFrame")

p <- rasterToPolygons(relief, dissolve=TRUE)


class(relief)
class(relief_spdf)

relief_spdf

# relief is converted to a very simple data frame, 
# just as the fortified municipalities.
# for that we need to convert it to a 
# SpatialPixelsDataFrame first, and then extract its contents 
# using as.data.frame
reliefdf <- as.data.frame(relief_spdf) %>% 
  rename(value = `X02.relief.georef.clipped.resampled`) %>% 
  tbl_df()

reliefdf

count(reliefdf, value, sort = TRUE) 

reliefgeojson <- reliefdf %>% 
  mutate(value = paste0("g", value),
         x = x/max(x),
         y = y/max(y)) %>% 
  geojson_json(lat = "x", lon = "y", group = "value", geometry = "polygon")

