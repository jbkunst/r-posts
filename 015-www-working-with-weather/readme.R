#' ---
#' title: "Working Wheather Data"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---

#+ fig.width=10, fig.height=5

rm(list = ls())
suppressWarnings(library("dplyr"))
suppressWarnings(library("lubridate"))
suppressWarnings(library("ggplot2"))
suppressWarnings(library("ggthemes"))

load("wheather_data.RData")

str(data)

data <- data %>% 
  mutate(date2 = dmy(date),
         year = year(date2),
         month = month(date2),
         day = day(date2))

ggplot(data) + 
  geom_line(aes(date2, temperature)) + 
  facet_grid(month ~ year, scales = "free")



