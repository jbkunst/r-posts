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
#' If you search a little in the devTools in the 
#' 
url_base <- "http://graphics8.nytimes.com/newsgraphics/2016/01/01/weather/assets"
file <- "new-york_ny.csv" # "san-francisco_ca.csv"
url_file <- file.path(url_base, file)

data <- read_csv(url_file)
glimpse(data)

data <- mutate(data, dt = datetime_to_timestamp(date))

options(highcharter.theme = hc_theme_smpl())


#' ## Setup
#' 
#' Lorem lorem setup
#' 
hc <- highchart() %>%
  hc_xAxis(type = "datetime", showLastLabel = FALSE,
           dateTimeLabelFormats = list(month = "%B")) %>% 
  hc_tooltip(shared = TRUE, useHTML = TRUE,
             headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))) %>% 
  hc_plotOptions(series = list(borderWidth = 0, pointWidth = 4))

hc

#' _No data to display_. All acording to the plan XD.
#' 
#' ## Temperature Data
#' 
#' We'll select the temperature columns from the data and do some wrangling,
#' gather, spread, separate and recodes to get a nice tidy data frame.
#' 
dtempgather <- data %>% 
  select(dt, starts_with("temp")) %>% 
  select(-temp_rec_high, -temp_rec_low) %>% 
  rename(temp_actual_max = temp_max,
         temp_actual_min = temp_min) %>% 
  gather(key, value, -dt) %>% 
  mutate(key = str_replace(key, "temp_", "")) 

dtempspread <- dtempgather %>% 
  separate(key, c("serie", "type"), sep = "_") %>% 
  spread(type, value)

temps <- dtempspread %>% 
  mutate(serie = factor(serie, levels = c("rec", "avg", "actual")),
         serie = fct_recode(serie, Record = "rec", Normal = "avg", Observed = "actual"))

temps

#' Now whe can add this data to the _highchart_ object using `hc_add_series`:

hc <- hc %>% 
  hc_add_series(temps, type = "columnrange",
                hcaes(dt, low = min, high = max, group = serie),
                color = c("#ECEBE3", "#C8B8B9", "#A90048")) 

hc

#' A really similar chart of what we want!
#' 
#' The chart show records of temprerature. So 
#' we need to filter the days with temperature records using the columns
#' `temp_rec_high` and `temp_rec_low`, then some gathers and tweaks. Then
#' set some options to show the points, like use fill color and some longer
#' radius.
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

#' We're good.
#' 
#' ## Precipitation Data
#' 
#' A nice feture of the NYTs app is and the chart is show the precipitaion by
#' month. This data is in other axis. So we need to create a list with 2 axis 
#' using the `create_yaxis` helper and the adding this axis to the chart.
axis <- create_yaxis(
  naxis = 2,
  heights = c(3,1),
  sep = 0.05,
  turnopposite = FALSE,
  showLastLabel = FALSE,
  startOnTick = FALSE)

#' 
#' Manually add titles (I know this can be more elegant) adn options.
#' 
axis[[1]]$title <- list(text = "Temperature")
axis[[1]]$labels <- list(format = "{value}°F")

axis[[2]]$title <- list(text = "Precipitation")
axis[[2]]$min <- 0

hc <- hc_yAxis_multiples(hc, axis)

hc

#' The 2 axis are ready, now we need add the data. We will add 12 series 
#' -one for each month- but we want to asociate 1 legend for all these 12 
#' series, so we need to use `id` and `linkedTo` parameters and obviously. 
#' That's why the `id` will be a `'p'` for the firt element and then `r NA`
#' to the other 11. And then linked this 11 to the first series (`id = 'p'`).

precip <- select(data, dt, precip_value, month)

hc <- hc %>%
  hc_add_series(precip, type = "area", hcaes(dt, precip_value, group = month),
                name = "Precipitation", color = "#008ED0", lineWidth = 1,
                yAxis = 1, fillColor = "#EBEAE2", 
                id = c("p", rep(NA, 11)), linkedTo = c(NA, rep("p", 11)))

#' The same way we'll add the normal precipitations by month.
#' 
precipnormal <- data %>% 
  select(dt, precip_normal, month) %>% 
  group_by(month) %>% 
  filter(row_number() %in% c(1, n())) %>%
  ungroup() %>% 
  fill(precip_normal)

hc <- hc %>% 
  hc_add_series(precipnormal, "line", hcaes(x = dt, y = precip_normal, group = month),
                name = "Normal Precipitation", color = "#008ED0", yAxis = 1,
                id = c("np", rep(NA, 11)), linkedTo = c(NA, rep("np", 11)),
                lineWidth = 1)
  

#' 
#' ## Volia
#' 
#' Curious how the chart looks? Me too! Crossing fingers...
#' 
hc


#' So, with R you can create a press style chart with some wrangling and charting. 
#' Now with a little of love we can make the code resuable to make a shiny app.
#' 
#' <iframe src="https://jbkunst.shinyapps.io/shiny-nyt-temp/" width="100%" height="750px"
#' style="border:none;"></iframe>
#' 