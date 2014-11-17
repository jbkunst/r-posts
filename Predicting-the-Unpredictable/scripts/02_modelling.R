rm(list=ls())

library(plyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(randomForest)
library(risk)
library(reuse)

load("../data/data_clean.rdata")
source("../scripts/helpers.R")

head(data)
table(data$LABEL.BUY)
str(data)
data <- data %>% mutate(LABEL.BUY = ifelse(LABEL.BUY==2, 0, LABEL.BUY))
table(data$LABEL.BUY)


periodos <- sort(unique(data$periodo))
ventanas <- getWindows(periodos, n.months.train = 6, n.months.val = 2)
