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
library("stringr")
library("purrr")
library("ggplot2")
library("highcharter")


#'
#' Read data
#' 

# http://www.dtpm.gob.cl/index.php/2013-04-29-20-33-57/matrices-de-viaje
zipfile <- tempfile(fileext = "gtfs.zip")
download.file("http://datos.gob.cl/dataset/8583ae05-d62f-42d7-a56d-4f865711b65a/resource/dc31a5c7-e717-4b9d-a9a6-93b4d4d2aaca/download/gtfsv17.zip",
              zipfile, mode = "wb")

fls <- unzip(zipfile, list = TRUE)

for (fl in fls$Name) {
  
  dfname <- str_c("df", str_replace(fl, "\\.txt", ""))
  assign(dfname, read_csv(unz(zipfile, fl)))
  
}

rm(fls, fl, dfname, zipfile)
# fix
names(dfroutes)[1] <- "route_id"
names(dfstops)[1] <- "stop_id"

routesMetro <- dfroutes %>%
  filter(agency_id == "M") %>% 
  mutate(route_id = str_replace(route_id, "_.*", ""),
         route_color = str_c("#", route_color),
         route_text_color = str_c("#", route_text_color)) %>% 
  select(route_id, route_long_name, route_color, route_text_color, route_url)

metrocols <- setNames(routesMetro$route_color, routesMetro$route_id)

shapesMetro <- dfshapes %>% 
  filter(str_detect(shape_id, "^L"), str_detect(shape_id, "-R_")) %>% 
  mutate(shape_id = str_replace(shape_id, "-R.*", "")) %>%
  arrange(shape_id, shape_pt_sequence)

stropsMetro <- dfstops %>% 
  filter(!is.na(stop_url))

ggplot() + 
  geom_path(data = shapesMetro, aes(shape_pt_lon, shape_pt_lat, group = shape_id, color = shape_id),
            size = 2) + 
  geom_point(data = stropsMetro, aes(stop_lon, stop_lat), color = "black", size = 2) + 
  geom_point(data = stropsMetro, aes(stop_lon, stop_lat), color = "white", size = 1) +
  scale_color_manual(NULL, values = metrocols) + 
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "bottom",  legend.key = element_blank())


dsstops <- stropsMetro %>% 
  select(x = stop_lon, y = stop_lat, url = stop_url, name = stop_name)

dsshapes <- left_join(shapesMetro, routesMetro, by = c("shape_id" = "route_id")) %>% 
  group_by(shape_id) %>% 
  do(serie = list(
    name = first(.$shape_id),
    color = first(.$route_color),
    data = list.parse2(data_frame(.$shape_pt_lon, .$shape_pt_lat)),
    lineWidth = 3,
    enableMouseTracking = FALSE,
    marker = list(enabled = FALSE)
  )) %>% 
  .$serie

stoptooltip <- list(
  pointFormat = "{point.name}<br>{point.stop_url}<a href=\"{point.stop_url}\">url</a>",
  useHTML = TRUE
)

stopsmarkeropts <- list(
  enabled = TRUE,
  fillColor = "white",
  lineWidth = 1,
  radius = 3,
  lineColor = "#545454",
  states = list(
    hover = list(
      fillColor = "white",
      lineColor = "#545454"
    )
  )
)

highchart() %>%
  hc_chart(type = "scatter") %>% 
  hc_add_series_list(dsshapes) %>% 
  hc_add_series_df(dsstops, name = "Stations",
                   marker = stopsmarkeropts,
                   tooltip = stoptooltip) %>% 
    hc_add_theme(hc_theme_null())

#' 
#' Nice!
#' 
