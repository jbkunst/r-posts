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
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")

#'
library(weatherData)
library(highcharter)
library(dplyr)
library(lubridate)
library(purrr)


#' # Data
data <- getDetailedWeather("KSFO", Sys.Date() - 1)

names(data) <- tolower(names(data))

data <- tbl_df(data)

data$time <- Sys.Date() - 1 + hms(sprintf("%s:00:00", 0:24))


sky_colors <- list(
  list(0.00, '#000000'),
  list(0.10, '#000000'),
  list(0.25, '#92DDF4'),
  list(0.50, '#7EC0EE'),
  list(0.75, '#7EC0EE'),
  list(23/24, '#101035'),
  list(1.00, '#000000')
)

sky_colors <- map(sky_colors, function(x){
  x[[2]] <- hex_to_rgba(x[[2]], alpha = 0.85)
  x
})


#' # Chart
highchart() %>% 
  hc_chart(
    type = "spline",
    backgroundColor = list(
      linearGradient = list(x1 = 0, x2 = 1, y1 = 0, y2 = 0),
      stops = sky_colors
      )
    ) %>% 
  hc_add_series_times_values(data$time, data$temperaturec) %>% 
  hc_yAxis(min = 0) %>% 
  hc_xAxis(labels = list(format = "{value:%H:%M}"),
           showFirstLabel = FALSE, showLastLabel = FALSE)
