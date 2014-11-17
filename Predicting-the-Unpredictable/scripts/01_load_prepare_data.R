rm(list=ls())

library(plyr)
library(dplyr)
library(lubridate)
library(ggplot2)

load("../data/data.RData")

head(data[, 1:15])

data <- data %>%
  mutate(date = ymd(substr(Fecha.ini, 0, 10)),
         periodo = format(date, "%Y%m")) %>%
  select(-muestra, -id, -prediccion, -dMax, -dMin, -Fecha.ini, -Fecha.fin, -LABEL.SELL)
  
head(data[, 1:15])
head(data[, 170:ncol(data)])



ggplot(data) + geom_bar(aes(date, fill=factor(LABEL.BUY))) 
ggplot(data) + geom_bar(aes(periodo, fill=factor(LABEL.BUY)))
ggplot(data) + geom_bar(aes(format(date, "%Y"), fill=factor(LABEL.BUY)))


save(data, file="../data//data_clean.rdata")

  