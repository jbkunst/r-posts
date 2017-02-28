#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "",
                      fig.showtext = TRUE, dev = "CairoPNG")

#'
#' # Data
#'
library(tidyverse) 
library(highcharter)

data <- read_delim("https://raw.githubusercontent.com/cristianst85/GeoNuclearData/master/data/csv/denormalized/nuclear_power_plants.csv", ";")

glimpse(data)

data <- arrange(data, ConstructionStartAt)

data <- mutate(data, constructed = 1, constructed = cumsum(constructed))


hchart(data, "line", hcaes(ConstructionStartAt, constructed))


data <- arrange(data, OperationalFrom)

data <- mutate(data, operational = 1, operational = cumsum(operational))


hchart(data, "line", hcaes(OperationalFrom, operational))


