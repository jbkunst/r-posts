#' ---
#' title: "Interactive Wheather Chart a la Tufte"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#' So much time since my last post, so I decided  to post something, no matter
#' what it is, but I hope this will be somehow helpful.
#'  
#' In this post, I will show some new features for the next version of 
#' Highcharter package. The main feature added is `hc_add_series`, now it is a
#' _generic_ function! This mean you can add the data argument as numeric,
#' data frame, time series (ts, xts, ohlc) among others, this way the syntax
#' is much cleaner.
#' 
#' What we'll do here? We'll make an interactive version of the 
#' _well-well-know-and-a-little-repeated_ Tufte weather chart.
#' 
#' The goal is to set up a chart similar to the New York Time App: _How Much
#' Warmer Was Your City in 2015?_ Where you can choose among 
#' over _3K cities_!. Let's start. 
#' 
#' ![](http://www.edwardtufte.com/bboard/images/00014g-837.gif "Weather Chart")
#' 
#' There are good ggplot versions if you can start there.
#' 
#' - https://rpubs.com/tyshynsk/133318
#' - https://rpubs.com/bradleyboehmke/weather_graphic
#' 
#' ## Data
#' 
#' First, last start with locating the data; A quick search...
#' 
#' If you search/explore in the devTools in the previous link, you can
#' know where is the path of the used data. So to be clear:
#' 
#' > All the data used in this post is from http://www.nytimes.com
#' > -- <cite>Me.</cite>
#' 
#' 
#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE)


#' We'll load the `tidyverse`, download the data, and create an auxiliar 
#' variable `dt` to store the date time in numeric format.

library(tidyverse)
library(highcharter)
library(lubridate)
library(stringr)
library(forcats)

url_base <- "http://graphics8.nytimes.com/newsgraphics/2016/01/01/weather/assets"
file <- "new-york_ny.csv" # "san-francisco_ca.csv"
url_file <- file.path(url_base, file)

data <- read_csv(url_file)
data <- mutate(data, dt = datetime_to_timestamp(date))

glimpse(data)

#' ## Setup
#' 
#' Due the data is ready we'll start to create the chart (a highchart object):
#' 
hc <- highchart() %>%
  hc_xAxis(type = "datetime", showLastLabel = FALSE,
           dateTimeLabelFormats = list(month = "%B")) %>% 
  hc_tooltip(shared = TRUE, useHTML = TRUE,
             headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))) %>% 
  hc_plotOptions(series = list(borderWidth = 0, pointWidth = 4)) %>% 
  hc_add_theme(hc_theme_smpl())

hc

#+ echo=FALSE
export_hc(hc, "nyt01.js")

#' > _No data to display_. All acording to the plan XD.
#' 
#' ## Temperature Data
#' 
#' We'll select the temperature columns from the data and do some wrangling,
#' gather, spread, separate and recodes to get a nice __tidy data frame__.
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

head(temps)

#' Now whe can add this data to the _highchart_ object using `hc_add_series`:

hc <- hc %>% 
  hc_add_series(temps, type = "columnrange",
                hcaes(dt, low = min, high = max, group = serie),
                color = c("#ECEBE3", "#C8B8B9", "#A90048")) 

hc

#+ echo=FALSE
export_hc(hc, "nyt02.js")

#' A really similar chart of what we want!
#' 
#' The original chart show records of temprerature. So 
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

pointsyles <- list(
  symbol = "circle",
  lineWidth= 1,
  radius= 4,
  fillColor= "#FFFFFF",
  lineColor = NULL
)

head(records)

hc <- hc %>% 
  hc_add_series(records, "point", hcaes(x = dt, y = value, group = type),
                marker = pointsyles)

hc

#+ echo=FALSE
export_hc(hc, "nyt03.js")

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
#' Manually add titles (I know this can be more elegant) and options.
#' 
axis[[1]]$title <- list(text = "Temperature")
axis[[1]]$labels <- list(format = "{value}°F")

axis[[2]]$title <- list(text = "Precipitation")
axis[[2]]$min <- 0

hc <- hc_yAxis_multiples(hc, axis)

hc

#+ echo=FALSE
export_hc(hc, "nyt04.js")

#' The two axes are ready, now we need to add the data. We will add 12 series
#' -one for each month- but we want to associate one legend for all these 
#' 12 series, so we need to use `id` and `linkedTo` parameters and obviously. 
#' That's why the id will be a `"p"` for the first element and then `NA` to
#' the other 11 elements and then linked those 11 elements to the first series
#' (`id = 'p'`).
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
#' Curious how the chart looks? Me too! Nah, I saw the chart before this post.
#' 
hc

#+ echo=FALSE
export_hc(hc, "nyt05.js")

#' With R you can create press style chart with some wrangling and charting. 
#' Now with a little of love we can make the code resuable to make a shiny app.
#' 
#' <iframe src="https://jbkunst.shinyapps.io/shiny-nyt-temp/" width="100%" height="750px"
#' style="border:none;"></iframe>
#' 
#' ## Homework
#' 
#' I will be grateful if someone will set grid lines for two axes as 
#' the original app, feel free to share the code.
#' 
#' See you :B!
#' 