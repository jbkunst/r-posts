#' ---
#' title: "Thematic Interactive Map"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE,  fig.cap = "", dev = "CairoPNG")

#' Last week all the _rstatsosphere_ see the beautiful 
#' [Timo Grossenbacher](timogrossenbacher.ch) work.
#' 
#' The last month, yep, the past year I've working on create map
#' easily with highcharter. When I saw this chart I took as 
#' challege so:
#' 
#' http://giphy.com/gifs/fangirl-challenge-13Vjd8PZuKxu2Q
#' 
#' 

# packages ----------------------------------------------------------------
library(dplyr)
library(maptools)
library(highcharter)
library(geojsonio)
library(rmapshaper)
library(readr)
library(viridis)
library(purrr)

#' ## Data
#' 
#' The data used fhor this chart is the same using by Timo. But the workflow
#' was slightly modified:
#' 
#' 1. Read the shapefile with `maptools::readShapeSpatial`.
#' 2. Simplify the shapefile (optional step) using `rmapshaper::ms_simplify`.
#' 3. Then transform the map data to geojson using `geojsonio::geojson_list`.
#' 
#' 
#+ echo=FALSE
# data --------------------------------------------------------------------
folder <- "~/../Downloads/thematic-maps-ggplot2-master/"

map <- readShapeSpatial(file.path(folder, "input/geodata/gde-1-1-15.shp"))
map <- ms_simplify(map, keep = 1) # because ms_simplify fix the ü's
map <- geojson_list(map)

str(map, max.level = 1)
str(map$features[[7]], max.level = 5)

# this was to put the name on the tooltip
map$features <- map(map$features, function(x) {
  x$properties$name <- x$properties[["Secondary_"]] 
  x
})

data <- read_csv(file.path(folder, "input/avg_age_15.csv")) 
data <- select(data, -X1)
data <- rename(data, value = avg_age_15)

# colors
no_classes <- 6

colors <- magma(no_classes + 2) %>% 
  rev() %>% 
  head(-1) %>% 
  tail(-1) %>% 
  gsub("FF$", "", .)

# brks <- quantile(data$value, probs = seq(0, 1, length.out = no_classes + 1))
brks <- c(min(data$value), c(40,42,44,46,48), max(data$value))
brks <- ifelse(1:(no_classes + 1) < no_classes, floor(brks), ceiling(brks))


#' ## Map
#' 
#' Create the raw map is straightforward. The _main_ challege was replicate the 
#' relief feature of the orignal map. This took _some days_ to figure
#' how add the backgound image. I almost loose the hope but you know, new year,
#' so I tried a little more and it was possible :):
#' 
#' 1. First I searched a way to transform the _tif_ image to geojson. I wrote
#' a mail to get the answer to  this but the reply said I was wrong XD. NEXT!
#' 2. I tried with use `divBackgroundImage` but with this the image use all the
#' container... so... NEXT.
#' 3. Finally surfing in the web I met `plotBackgroundImage` argument in highcharts
#' which is uesd to put and image only in plot container (inside de axis) and 
#' it works nicely. It was necessary hack the image using the `preserveAspectRatio`
#' (html world) to center the image but nothing magical. 
#' 
#' 
urlimage <- "https://raw.githubusercontent.com/jbkunst/r-posts/master/061-beautiful-thematic-maps-with-ggplot2-highcharter-version/02-relief-georef-clipped-resampled.jpg"

highchart(type = "map") %>% 
  # data part
  hc_add_series(mapData = map, data = data, type = "map",
                joinBy = c("BFS_ID", "bfs_id"), value = "value",
                borderWidth = 0) %>% 
  hc_colorAxis(dataClasses = color_classes(brks, colors)) %>% 
  # functionality
  hc_tooltip(headerFormat = "",
             pointFormat = "{point.name}: {point.value}",
             valueDecimals = 2) %>% 
  hc_legend(align = "right", verticalAlign = "bottom", layout = "vertical",
            floating = TRUE) %>%
  hc_mapNavigation(enabled = FALSE) %>% # if TRUE to zoom the relief image dont zoom.
  # info
  hc_title(text = "Switzerland's regional demographics") %>% 
  hc_subtitle(text = "Average age in Swiss municipalities, 2015") %>% 
  hc_credits(enabled = TRUE,
             text = "Map CC-BY-SA; Author: Joshua Kunst (@jbkunst) based mostly on Timo Grossenbacher (@grssnbchr) work, Geometries: ThemaKart, BFS; Data: BFS, 2016; Relief: swisstopo, 2016") %>% 
  # style
  hc_chart(plotBackgroundImage = urlimage,
           backgroundColor = "transparent",
           events = list(
             load = JS("function(){ $(\"image\")[0].setAttribute('preserveAspectRatio', 'xMidYMid') }")
           ))

#' Same as the original/ggplot2 version! 
#' 
#' The are some details like:
#' 
#' 1. The image/relief need to be accesible in web. I don't know how
#' to add dependencies as images. I tried econding the image but didn't work.
#' 2. I could not do the legend same as the original. So I used `dataClasses`
#' instead of `stops` in `hc_colorAxis`. 
  