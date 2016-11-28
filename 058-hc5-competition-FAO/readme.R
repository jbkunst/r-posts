#' ---
#' title: "Highcharts 5 Competition"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
# setup -------------------------------------------------------------------
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

#' Load Packages
library(tidyverse)
library(highcharter)
library(janitor)
library(broom)

# data --------------------------------------------------------------------
#' ## Data
#' 
#' Teh data come from http://faostat3.fao.org/download/T/TM/E

data <- read_csv("~/../Downloads/5de0c84f-65a5-4bcc-8fae-b44be8430358.csv")
data <- clean_names(data)
glimpse(data)


data <- select(data, -ends_with("code"), -contains("record"), -contains("flag"),
               -domain, -year)
glimpse(data)

count(data, unit, element, sort = TRUE)


dataexports <- data %>% 
  filter(element == "Export Value") %>% 
  group_by(country = reporter_countries, item) %>% 
  summarize(value = sum(value)) %>% 
  group_by(country) %>% 
  mutate(percent = value/sum(value)) %>% 
  arrange(country, percent) %>% 
  mutate(percentcum = cumsum(percent),
         item2 = ifelse(percentcum < .25, "other", item))

dataexports2 <- dataexports %>% 
  group_by(country,  item2) %>% 
  summarize(value = sum(value),
            percent = sum(percent))

hchart(dataexports2, type = "heatmap", x = item2, y = country, value = percent) %>% 
  hc_colorAxis(stops = color_stops(10, viridisLite::viridis(10, alpha = 0)))



