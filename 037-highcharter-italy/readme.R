#' ---
#' title: "Highcharter Italy Map"
#' author: "Joshua Kunst"
#' output: html_document
#' ---

#+ warning=FALSE
rm(list = ls())
library("highcharter")
library("dplyr")
library("purrr")
library("geojsonio")
library("httr")

#' # Simple


map <- "https://raw.githubusercontent.com/stefanocudini/leaflet-geojson-selector/master/examples/italy-regions.json" %>% 
  GET() %>% 
  content() %>% 
  jsonlite::fromJSON(simplifyVector = FALSE)


map$features[[1]]$properties

dfita1 <-  map$features %>% 
  map_df(function(x){
    as_data_frame(x$properties)
  })

head(dfita1)

highchart(type = "map") %>% 
  hc_add_series_map(map = map, df = dfita1, joinBy = "id", value = "length") 
  
  

#' # A little more complex

url <- "http://code.highcharts.com/mapdata/countries/it/it-all.geo.json"
tmpfile <- tempfile(fileext = ".json")
download.file(url, tmpfile)

ita <- readLines(tmpfile)
ita <- gsub(".* = ", "", ita)
ita <- jsonlite::fromJSON(ita, simplifyVector = FALSE)


#' 
#' get id the regions/states 
#' 

x <- ita$features[[1]]
x$properties

dfita2 <-  ita$features %>% 
  map_df(function(x){
    data_frame(hasc = x$properties$hasc, name = x$properties$name)
  }) %>%  # extract the keys
  mutate(random = runif(nrow(.))) # create random value

head(dfita2)

highchart(type = "map") %>% 
  hc_title(text = "Airports in Australia") %>% 
  hc_add_series_map(map = ita, df = dfita2, joinBy = "hasc", value = "random")
  
