#' ---
#' title: "Wheather chart a la Tufte"
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

#'
library(tidyverse)
library(highcharter)
library(lubridate)
library(stringr)
library(forcats)

#' ## Data
#' 
#' Lorem lorem
#' 
url_base <- "http://graphics8.nytimes.com/newsgraphics/2016/01/01/weather/assets"
file <- "new-york_ny.csv" # "san-francisco_ca.csv"
url_file <- file.path(url_base, file)

data <- read_csv(url_file)
glimpse(data)

data <- mutate(data, dt = datetime_to_timestamp(date))

options(highcharter.theme = hc_theme_smpl(),
        highcharter.debug = TRUE)


#' ## Setup
#' 
#' Lorem lorem setup
#' 
hc <- highchart() %>%
  # axis setup
  hc_xAxis(type = "datetime",
           dateTimeLabelFormats = list(month = "%B"),
           showLastLabel = FALSE) %>% 
  # setting tooltip
  hc_tooltip(shared = TRUE,
             useHTML = TRUE,
             headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))) %>% 
  hc_plotOptions(series = list(borderWidth = 0, pointWidth = 4))

hc

#' ## Adding temp data
#' 
#'  Some fun wrangling the data, some gather, some spread.
#' 
#' 
dtempgather <- data %>% 
select(dt, starts_with("temp")) %>% 
  select(-temp_rec_high, -temp_rec_low) %>% 
  rename(temp_actual_max = temp_max,
         temp_actual_min = temp_min) %>% 
  gather(key, value, -dt) %>% 
  mutate(key = str_replace(key, "temp_", "")) 

dtempgather

dtempspread <- dtempgather %>% 
  separate(key, c("serie", "type"), sep = "_") %>% 
  spread(type, value)

dtempspread

#' Finaly some fixes
#' 

temps <- dtempspread %>% 
  mutate(serie = factor(serie, levels = c("rec", "avg", "actual")),
         serie = fct_recode(serie, Record = "rec", Normal = "avg", Observed = "actual"))

temps

#' So, why thiz codez? Just for get a tidy data for easy charting.

hc <- hc %>% 
  hc_add_series(temps, type = "columnrange",
                hcaes(dt, low = min, high = max, group = serie),
                color = c("#ECEBE3", "#C8B8B9", "#A90048")) 

hc

#' ## Records
records <- data %>%
  select(dt, temp_rec_high, temp_rec_low) %>% 
  filter(temp_rec_high != "NULL" | temp_rec_low != "NULL") %>% 
  dmap_if(is.character, str_extract, "\\d+") %>% 
  dmap_if(is.character, as.numeric) %>% 
  gather(type, value, -dt) %>% 
  filter(!is.na(value)) %>% 
  mutate(type = str_replace(type, "temp_rec_", ""),
         type = paste("This year record", type))

records

pointsyles <- list(
  symbol = "circle",
  lineWidth= 1,
  radius= 4,
  fillColor= "#FFFFFF",
  lineColor= NULL
)


hc <- hc %>% 
  hc_add_series(records, "point", hcaes(x = dt, y = value, group = type),
                marker = pointsyles)

hc

#' ## Adding other data in other axis
#' 
#' First create a list with 2 axis and using the  `create_yaxis` helper
axis <- create_yaxis(
  naxis = 2,
  heights = c(3,1),
  sep = 0.05,
  turnopposite = FALSE,
  showLastLabel = FALSE,
  startOnTick = FALSE)

#' Manually add titles (I know this can be more elegant)
axis[[1]]$title <- list(text = "Temperature")
axis[[1]]$labels <- list(format = "{value}°F")

axis[[2]]$title <- list(text = "Precipitation")
axis[[2]]$min <- 0

hc <- hc_yAxis_multiples(hc, axis)

hc

#' Te 2 axis are ready, now just add the data. Here we will add 12 series 
#' -one for each month- but we want to asociate 1 legend for all these 12 
#' series, so we need to use `id` and `linkedTo` parameters and obviously
#' add this data to the second axis.

precip <- select(data, dt, precip_value, month)

hc <- hc %>%
  hc_add_series(precip, type = "area", hcaes(dt, precip_value, group = month),
                name = "Precipitation", color = "skyblue", yAxis = 1,
                id = c("p", rep(NA, 11)), linkedTo = c(NA, rep("p", 11)))

hc

#' Normal precipitations
#' 
precipnormal <- select(data, dt, precip_normal, month) %>% 
  group_by(month) %>% 
  filter(row_number() %in% c(1, n())) %>%
  ungroup() %>% 
  fill(precip_normal)

hc <- hc %>% 
  hc_add_series(precipnormal, "line", hcaes(x = dt, y = precip_normal, group = month),
                name = "Normal Precipitation", color = "#C8B8B9", yAxis = 1,
                id = c("np", rep(NA, 11)), linkedTo = c(NA, rep("np", 11)),
                lineWidth = 1)
  


#' ## Volia
hc

