# 
Joshua Kunst  



This script is inspired and some copy&paste from https://rpubs.com/chengjiun/52658

# Data


```r
library(dplyr)
library(lubridate)
df <- readr::read_csv("train.csv")

head(df)
```

```
## Source: local data frame [6 x 12]
## 
##              datetime season holiday workingday weather  temp  atemp
##                (time)  (int)   (int)      (int)   (int) (dbl)  (dbl)
## 1 2011-01-01 00:00:00      1       0          0       1  9.84 14.395
## 2 2011-01-01 01:00:00      1       0          0       1  9.02 13.635
## 3 2011-01-01 02:00:00      1       0          0       1  9.02 13.635
## 4 2011-01-01 03:00:00      1       0          0       1  9.84 14.395
## 5 2011-01-01 04:00:00      1       0          0       1  9.84 14.395
## 6 2011-01-01 05:00:00      1       0          0       2  9.84 12.880
## Variables not shown: humidity (int), windspeed (dbl), casual (int),
##   registered (int), count (int)
```

```r
df <- df %>% 
  mutate(year = year(datetime),
         month = month(datetime),
         day = day(datetime),
         hour = hour(datetime)) %>% 
  select(-datetime)


formula <- count ~ .
```


# Models

---
title: "readme.R"
author: "jkunst"
date: "Fri May 06 15:44:13 2016"
---
