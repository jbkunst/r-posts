#' ---
#' title: "Global Temperatures"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.showtext = TRUE, dev = "CairoPNG")
library("highcharter")
library("readr")
library("dplyr")
library("tidyr")
library("lubridate")
library("purrr")
library("viridis")
options(highcharter.theme = hc_theme_darkunica(chart  = list(style = list(fontFamily = "Roboto Condensed"))))

#'
#' ## Data
#' 

df <- read_csv("https://raw.githubusercontent.com/hrbrmstr/hadcrut/master/data/temps.csv")

df <- df %>% 
  mutate(date = ymd(year_mon),
         tmpstmp = datetime_to_timestamp(date),
         year = year(date),
         month = month(date, label = TRUE),
         color_m = colorize(median, viridis(10)),
         color_m = hex_to_rgba(color_m, 0.65))

dfcolyrs <- df %>% 
  group_by(year) %>% 
  summarise(median = median(median)) %>% 
  ungroup() %>% 
  mutate(color_y = colorize(median, viridis(10)),
         color_y = hex_to_rgba(color_y, 0.65)) %>% 
  select(-median)

df <- left_join(df, dfcolyrs, by = "year")

#'
#' ## Spiral
#' 
lsseries <- df %>% 
  group_by(year) %>% 
  do(
    data = .$median,
    color = first(.$color_y)) %>% 
  mutate(name = year) %>% 
  list.parse3()

hc1 <- highchart() %>% 
  hc_chart(polar = TRUE) %>% 
  hc_plotOptions(series = list(marker = list(enabled = FALSE), animation = TRUE, pointIntervalUnit = "month")) %>%
  hc_legend(enabled = FALSE) %>% 
  hc_xAxis(type = "datetime", min = 0, max = 365 * 24 * 36e5,  labels = list(format = "{value:%B}")) %>%
  hc_tooltip(headerFormat = "{point.key}", xDateFormat = "%B", pointFormat = " {series.name}: {point.y}") %>% 
  hc_add_series_list(lsseries)

hc1

#' ### Spiral w/animation

lsseries2 <- df %>% 
  group_by(year) %>% 
  do(
    data = .$median,
    color = "transparent",
    enableMouseTracking = FALSE,
    color2 = first(.$color_y)) %>% 
  mutate(name = year) %>% 
  list.parse3()

hc11 <- highchart() %>% 
  hc_chart(polar = TRUE) %>% 
  hc_plotOptions(series = list(marker = list(enabled = FALSE), animation = TRUE, pointIntervalUnit = "month")) %>%
  hc_legend(enabled = FALSE) %>% 
  hc_xAxis(type = "datetime", min = 0, max = 365 * 24 * 36e5,  labels = list(format = "{value:%B}")) %>%
  hc_tooltip(headerFormat = "{point.key}", xDateFormat = "%B", pointFormat = " {series.name}: {point.y}") %>% 
  hc_add_series_list(lsseries2) %>% 
  hc_chart(
    events = list(
      load = JS("

function() {
  console.log('ready');
  var duration = 16 * 1000
  var delta = duration/this.series.length;
  var delay = 0;

  this.series.map(function(e){
    setTimeout(function() {
      e.update({color: e.options.color2, enableMouseTracking: true});
      e.chart.setTitle(null, {text: e.name})
    }, delay)
    delay = delay + delta;
  });
}
                ")
    )
  )

# rm theme
hc11$x$theme <- list(chart = list(divBackgroundImage = NULL))

hc11

#'
#' ## Sesonalplot
#' 
hc2 <- hc1 %>% 
  hc_chart(polar = FALSE, type = "spline") %>% 
  hc_xAxis(max = (365 - 1) * 24 * 36e5)

hc2

#'
#' ## Columrange
#' 

ds <- df %>% 
  mutate(name = paste(decade, month)) %>% 
  select(x = tmpstmp, low = lower, high = upper, name, color = color_m)

hc3 <- highchart() %>% 
  hc_chart(type = "columnrange") %>% 
  hc_xAxis(type = "datetime") %>%
  hc_add_series_df(ds, name = "Global Temperature", showInLegend = FALSE)

hc3

#'
#' ## Heatmap
#' 
m <- df %>% 
  select(year, month, median) %>% 
  spread(year, median) %>% 
  select(-month) %>% 
  as.matrix() 

rownames(m) <- month.abb

hc4 <- hchart(m) %>% 
  hc_colorAxis(stops = color_stops(10, viridis(10))) %>% 
  hc_yAxis(title = list(text = NULL))

hc4
