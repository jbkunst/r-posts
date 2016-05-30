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
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.showtext = TRUE, dev = "CairoPNG")
library("highcharter")
library("readr")
library("dplyr")
library("tidyr")
library("lubridate")
library("purrr")
library("viridis")
options(highcharter.theme = hc_theme_smpl())

#'
#' ## Data
#' 

df <- read_csv("https://raw.githubusercontent.com/hrbrmstr/hadcrut/master/data/temps.csv")

df <- df %>% 
  mutate(date = ymd(year_mon),
         tmpstmp = datetime_to_timestamp(date),
         year = year(date),
         month = month(date, label = TRUE))

dfcolyrs <- df %>% 
  group_by(year) %>% 
  summarise(median = median(median)) %>% 
  ungroup() %>% 
  mutate(color = colorize(median, viridis(10)),
         color = hex_to_rgba(color, 0.65),
         delay = seq(1, 5000, length.out = nrow(.))) %>% 
  select(-median)

df <- left_join(df, dfcolyrs, by = "year")

#'
#' ## Spiral
#' 
lsseries <- df %>% 
  group_by(year) %>% 
  do(series = list(
    name = first(.$year),
    data = .$median,
    color = first(.$color),
    animation = list(delay = first(.$delay))
  )) %>% 
  .$series

lsseries[[1]]


hc1 <- highchart() %>% 
  hc_chart(polar = TRUE) %>% 
  hc_plotOptions(series = list(marker = list(enabled = FALSE), animation = TRUE, pointIntervalUnit = "month")) %>%
  hc_legend(enabled = FALSE) %>% 
  hc_xAxis(type = "datetime", min = 0, max = 365 * 24 * 36e5,  labels = list(format = "{value:%b}")) %>% 
  hc_add_series_list(lsseries)

hc1 

#'
#' ## Sesonalplot
#' 
hc2 <- hc1 %>% 
  hc_chart(polar = FALSE, type = "line") %>% 
  hc_xAxis(max = (365 - 1) * 24 * 36e5)

hc2

#'
#' ## Columrange
#' 

ds <- df %>% 
  mutate(name = paste(decade, month)) %>% 
  select(x = tmpstmp, low = lower, high = upper, name, color)

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

hchart(m)


