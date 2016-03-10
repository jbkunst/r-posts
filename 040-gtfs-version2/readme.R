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
library("stringr")
library("purrr")


#'
#' Read data
#' 
zipfile <- "gtfs.zip"

fls <- unzip(zipfile, list = TRUE)

for (fl in fls$Name) {
  
  dfname <- str_replace(fl, "\\.txt", "")
  
  assign(dfname, read_csv(unz(zipfile, fl)))
  
}

rm(fl, dfname)
# fix
names(routes)[1] <- "route_id"

routesMetro <- routes %>%
  filter(agency_id == "M",
         str_detect(route_id, "L\\dA?_V22"))


shapesMetro <- shapes %>% 
  filter(str_detect(shape_id, "^L1-R")) %>% 
  arrange(shape_id, shape_pt_sequence)

ggplot(shapesMetro) + 
  geom_line(aes(shape_pt_lat, shape_pt_lon, group = shape_id, color = shape_id))
