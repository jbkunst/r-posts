rm(list=ls())

library(plyr)
library(dplyr)
library(lubridate)
library(ggplot2)

load("../data/data_clean.rdata")
source("../scripts/helpers.R")

head(data)

periodos <- sort(unique(data$periodo))
ventanas <- getWindows(periodos, n.months.train = 2, n.months.val = 1)
