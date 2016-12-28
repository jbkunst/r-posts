#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

#'
rm(list = ls())
library(dplyr)
library(maptools)
library(highcharter)
library(geojsonio)
library(rmapshaper)
options(highcharter.debug = TRUE)

fldr <- "~/ME-GIS-master"

shp_to_geoj_smpl <- function(file = "Coastline2.shp", k = 0.5) {
  d <- readShapeSpatial(file.path(fldr, file))
  d <- ms_simplify(d, keep = k)
  d <- geojson_list(d)
  d
}

shp_points_to_geoj <- function(file) {
  outp <- readShapeSpatial(file.path(fldr, file))
  outp <- geojson_json(outp) 
  outp
}

  
cstln <- shp_to_geoj_smpl("Coastline2.shp", .65)
rvers <- shp_to_geoj_smpl("Rivers19.shp", .01)
frsts <- shp_to_geoj_smpl("Forests.shp", 0.90)
lakes <- shp_to_geoj_smpl("Lakes2.shp", 0.1)
roads <- shp_to_geoj_smpl("PrimaryRoads.shp", 1)


cties <- shp_points_to_geoj("Cities.shp")
towns <- shp_points_to_geoj("Towns.shp")


head(jsonlite::fromJSON(cties)$features$properties)
head(lakes$features[[1]]$properties)
  
pointsyles <- list(
  symbol = "circle",
  lineWidth= 1,
  radius= 4,
  fillColor= "transparent",
  lineColor= NULL
)

options(highcharter.verbose = TRUE)

hcme <- highchart(type = "map") %>% 
  hc_chart(style = list(fontFamily = "Macondo"), backgroundColor = "#F4C283") %>% 
  hc_title(text = "The Middle Earth", style = list(fontFamily = "Tangerine", fontSize = "40px")) %>% 
  hc_add_series(data = cstln, type = "mapline", color = "brown", name = "Coast") %>%
  hc_add_series(data = rvers, type = "mapline", color = "#7e88ee", name = "Rivers") %>%
  hc_add_series(data = roads, type = "mapline", color = "#634d53", name = "Main Roads") %>%
  hc_add_series(data = frsts, type = "map", color = "#228B22", name = "Forest") %>%
  hc_add_series(data = lakes, type = "map", color = "#7e88ee", name = "Lakes") %>%
  hc_add_series(data = cties, type = "mappoint", color = "black", name = "Cities",
                dataLabels = list(enabled = TRUE), marker = list(radius = 4, lineColor = "black")) %>%
  # hc_add_series(data = towns, type = "mappoint", color = "black", name = "Towns",
  #               dataLabels = list(enabled = TRUE), marker = list(radius = 1, fillColor = "rgba(190,190,190,0.7)")) %>%
  hc_plotOptions(
    series = list(
      marker = pointsyles,
      tooltip = list(headerFormat = "", poinFormat = "{series.name}"),
      dataLabels = list(enabled = FALSE, format = '{point.properties.Name}')
    )
  ) %>% 
  hc_mapNavigation(enabled = TRUE) 

hcme

# htmlwidgets::saveWidget(hcme, file = "~/hcme.html", selfcontained = FALSE)

library(purrr)
library(jsonlite)
library(readr)

hcmemin <- hcme

hcmemin$x$hc_opts$series <- map(hcmemin$x$hc_opts$series, function(x){
  
  y <<- x
  # x <- y
  nm <- x$name
  nmid <- str_to_id(nm)
  
  print(nmid)
  str(x$data, max.level = 1)
  
  data <- x$data
  
  print(as.character(cties))
  
  if(class(x$data)[1] == "json") {
    
    data <- fromJSON(as.character(x$data), simplifyVector = FALSE)
    
  }
  
  class(data) <- "list"
  str(data, max.level = 1)
  
  json <- toJSON(data, pretty = TRUE, auto_unbox = TRUE)
  json <- paste(nmid, " = ", json)
  
  write_lines(json, path = paste0("~/", str_to_id(nm), ".js"))
  
  x$data <- JS(nmid)
  x$geojson <- NULL
  x
  
})

export_hc(hcmemin, "~/middle-earth.js")
