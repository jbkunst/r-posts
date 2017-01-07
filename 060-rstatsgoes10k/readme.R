#' ---
#' title: "My Naive Attempt to rstatsgoes10k contest"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'  github_document:
#'    always_allow_html: yes
#'    toc: true
#' ---
#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE,  fig.cap = "", dev = "CairoPNG")

#' Last year [eoda.de](https://blog.eoda.de/2016/12/21/rstatsgoes10k-eoda-is-hosting-a-contest-in-celebration-of-r/)
#' launched a contest to predict when the R packages will be 10k. So this
#' is a really good opportunity to use  (at least) the `forecastHybrid` developed by 
#' [Peter Ellis](http://ellisp.github.io/) and David Shaub.
#' 
#' > This will be a really naive-simply-raw try to get a
#' > reasonable prediction. No transformations, no CV. etc. But you can do better!
#' > -- <cite>The writer.</cite>
#'  
#' Let's load the packages!
#' 
library(dplyr)
library(rvest)
library(janitor)
library(lubridate)
library(highcharter)
library(forecast)
library(forecastHybrid)
library(zoo)
options(highcharter.theme = hc_theme_smpl())

#' The data will be extracted from the list of packages by date from CRAN.
#' Then we'll make some wrangling to get the cumulative sum of the packages
#' by day.

packages <- "https://cran.r-project.org/web/packages/available_packages_by_date.html" %>% 
  read_html() %>% 
  html_table() %>%
  .[[1]] %>% 
  tbl_df()

names(packages) <- tolower(names(packages))

packages <- mutate(packages, date = ymd(date))

glimpse(packages)

c(min(packages$date), max(packages$date))

data <- packages %>% 
  group_by(date) %>% 
  summarise(n = n()) %>% 
  left_join(data_frame(date = seq(min(packages$date), max(packages$date), by = 1)),
            ., by = "date")

data <- data %>% 
  mutate(
    n = ifelse(is.na(n), 0, n),
    cumsum = cumsum(n)
  )

tail(data)

hchart(data, "line", hcaes(date, cumsum)) %>% 
  hc_title(text = "Packages by time")

#' 
#' A little weird the effect in the 2014. Let's drop some past
#' information and create some auxiliar variables.
#' 
data <- filter(data, year(date) >= 2013)

date_first <- first(data$date)
date_last <- last(data$date)

#' To use the package we need first a time series object:

z <- zooreg(data$cumsum, start = date_first, frequency = 1)
tail(z)


#'  Now, to use `forecastHybrid::hybridModel` I removed the `tbats` model
#'  due the long time to fit, the long time to make the cv and the long long
#'  time to make the predictions in my previous tests. So, in the spirit to 
#'  be parsimonious and simple we will remove this model from the fit.

# hm <- hybridModel(z, models = "aefns", weights = "cv.errors", errorMethod = "MASE")
# saveRDS(hm, "hm.rds")
hm <- readRDS("hm.rds")
hm

#' Make the forecast is really simple. After the calculate them we will
#' create a `data_frame` to filter and see what day R will have 10k 
#' packages according this methodology.

H <- 20
fc <- forecast(hm, h = H)

data_fc <- fc %>% 
  as_data_frame() %>% 
  mutate(date = date_last + days(1:H)) %>% 
  clean_names() %>% 
  tbl_df()

#' So let't see the point prediction and the _optimistic_ prediction
#' which is the upper limit from the 95% interval.

data_preds <- bind_rows(
  data_fc %>%
    filter(point_forecast >= 10000) %>%
    mutate(name = "Prediction") %>%
    head(1) %>% 
    rename(y = point_forecast),
  data_fc %>%
    filter(hi_95 >= 10000) %>%
    mutate(name = "Optimitstic prediction") %>%
    head(1) %>% 
    rename(y = hi_95)
)

select(data_preds, name, date, y)
  
#' > So soon!! (warning: according to this). 
#' 
#' Now, let's visualize the result.
#' 

highchart() %>% 
  hc_title(text = "rstatsgoes10k") %>%
  hc_subtitle(text = "Predictions via <code>forecastHybrid</code> package", useHTML = TRUE) %>% 
  hc_xAxis(type = "datetime",
           crosshair = list(zIndex = 5, dashStyle = "dot",
                            snap = FALSE, color = "gray"
           )) %>% 
  hc_add_series(filter(data, date >= ymd(20161001)), "line", hcaes(date, cumsum),
                name = "Packages") %>% 
  hc_add_series(data_fc, "line", hcaes(date, point_forecast),
                name = "Prediction", color = "#75aadb") %>% 
  hc_add_series(data_fc, "arearange", hcaes(date, low = lo_95, high = hi_95),
                name = "Prediction Interval (95%)", color = "#75aadb", fillOpacity = 0.3) %>% 
  hc_add_series(data_preds, "scatter", hcaes(date, y, name = name),
                name = "Predicctions to 10K", color = "blue",
                tooltip = list(pointFormat = ""), zIndex = -4,
                marker = list(symbol = "circle", lineWidth= 1, radius= 4,
                              fillColor= "transparent", lineColor= NULL),
                dataLabels = list(enabled = TRUE, format = "{point.name}<br>{point.x:%Y-%m-%d}",
                                  style = list(fontWeight = "normal"))) %>% 
  hc_tooltip(shared = TRUE, valueDecimals = 0)
  

#' Simple, right? Maybe the that will not be the day where R hit 10k packages but its
#' doesn't matter. The __really important__ fact here is all this is product of many many 
#' developers joined by the community, and some Rheroes like HW, JO, JB, GC, JC, BR, MA,
#' DR, JS, KR and many many others. Thanks to everybody I can using this versatile and powerful
#' language happily day by day.