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
knitr::opts_chunk$set(message=FALSE, warning=FALSE)

#' Source: http://www.arilamstein.com/blog/2016/01/25/mapping-us-religion-adherence-county-r/
#' 
#' This is a try to implement the choropleth using [highcarter](http://jkunst.com/highcharter),

#' Download the data:
#' 
library(haven)
library(dplyr)
library(stringr)

url <- "http://www.thearda.com/download/download.aspx?file=U.S.%20Religion%20Census%20Religious%20Congregations%20and%20Membership%20Study,%202010%20(County%20File).SAV"

data <- read_sav(url)

data[, tail(seq(ncol(data)), -560)]

data <- data %>% 
  mutate(CODE = paste("us",
                      tolower(STABBR),
                      str_pad(CNTYCODE, width = 3, pad = "0"),
                      sep = "-"))

data[, tail(seq(ncol(data)), -560)]


library(highcharter)
data("uscountygeojson")


#' Adding viridis palette:
#' 
require("viridisLite")
n <- 32
dstops <- data.frame(q = 0:n/n, c = substring(viridis(n + 1), 0, 7))
dstops <- list.parse2(dstops)


highchart() %>% 
  hc_title(text = "Total Religious Adherents by County") %>% 
  hc_add_series_map(map = uscountygeojson, df = data,
                    value = "TOTRATE", joinBy = c("code", "CODE"),
                    name = "Adherents", borderWidth = 0.5) %>% 
  hc_colorAxis(stops = dstops, min = 0, max = 1000) %>% 
  hc_legend(layout = "vertical", reversed = TRUE,
            floating = TRUE, align = "right") %>% 
  hc_mapNavigation(enabled = TRUE, align = "right") %>% 
  hc_tooltip(valueDecimals = 0)

