# https://blog.eoda.de/2016/12/21/rstatsgoes10k-eoda-is-hosting-a-contest-in-celebration-of-r/
rm(list = ls())
library(dplyr)
library(rvest)
library(janitor)
library(lubridate)
library(highcharter)
library(tidyr)
library(forecast)

options(highcharter.theme = hc_theme_smpl())

packages <- "https://cran.r-project.org/web/packages/available_packages_by_date.html" %>% 
  read_html() %>% 
  html_table() %>%
  .[[1]] %>% 
  tbl_df()

names(packages) <- tolower(names(packages))

packages <- mutate(packages, date = ymd(date))

glimpse(packages)

c(min(packages$date), max(packages$date))

data <- packages %>% 
  group_by(date) %>% 
  summarise(n = n()) %>% 
  left_join(data_frame(date = seq(min(packages$date), max(packages$date), by = 1)),
            ., by = "date")

data <- data %>% 
  mutate(
    n = ifelse(is.na(n), 0, n),
    cumsum = cumsum(n),
    log_cumsum = log(cumsum)
  )

hchart(data, "line", hcaes(date, cumsum))

data <- filter(data, year(date) >= 2013)

data %>% 
  select(-n) %>% 
  gather(key, value, -date) %>% 
  hchart("line", hcaes(date, value, group = key), yAxis = 0:1) %>% 
  hc_yAxis_multiples(create_yaxis(2))
    
head(data)

y <- ts(data$cumsum, frequency = 7)

library(forecast)
fit <- ets(y)
fc <- forecast(fit)
plot(fc)

y <- msts(x, seasonal.periods=c(7,365.25))
fit <- tbats(y)
fc <- forecast(fit)
plot(fc)


