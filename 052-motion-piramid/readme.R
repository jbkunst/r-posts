#' ---
#' title: "Motion Piramid"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")

#'
library(idbr)
library(dplyr)
library(purrr)
library(highcharter)
rm(list = ls())

idb_api_key("35f116582d5a89d11a47c7ffbfc2ba309133f09d")

yrs <-  seq(1980, 2030, by = 1)

df <- map_df(c("male", "female"), function(sex){
  idb1("US", yrs, sex = sex) %>%
    mutate(sex_label = sex)
})

names(df) <- tolower(names(df))

str(df)
head(df) 

df <- df %>%
  mutate(population = pop*ifelse(sex_label == "male", -1, 1))

series <- df %>% 
  group_by(sex_label, age) %>% 
  do(data = list(sequence = .$population)) %>% 
  ungroup() %>% 
  group_by(sex_label) %>% 
  do(data = .$data) %>%
  mutate(name = sex_label) %>% 
  list.parse3()

maxpop <- max(abs(df$population))

xaxis <- list(categories = sort(unique(df$age)),
              reversed = FALSE, tickInterval = 5,
              labels = list(step = 5))

highchart() %>%
  hc_chart(type = "bar") %>%
  hc_motion(enabled = TRUE, labels = yrs, series = c(0,1), autoplay = TRUE, updateInterval = 1) %>% 
  hc_add_series_list(series) %>% 
  hc_plotOptions(
    series = list(stacking = "normal"),
    bar = list(groupPadding = 0, pointPadding =  0, borderWidth = 0)
  ) %>% 
  hc_tooltip(shared = TRUE) %>% 
  hc_yAxis(
    labels = list(
      formatter = JS("function(){ return Math.abs(this.value) / 1000000 + 'M'; }") 
    ),
    tickInterval = 0.5e6,
    min = -maxpop,
    max = maxpop) %>% 
  hc_xAxis(
    xaxis,
    rlist::list.merge(xaxis, list(opposite = TRUE, linkedTo = 0))
  ) %>% 
  hc_tooltip(shared = FALSE,
             formatter = JS("function () { return '<b>' + this.series.name + ', age ' + this.point.category + '</b><br/>' + 'Population: ' + Highcharts.numberFormat(Math.abs(this.point.y), 0);}")
  ) %>% 
  hc_add_theme(hc_theme_smpl())

  
