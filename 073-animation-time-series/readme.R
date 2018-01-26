library(tidyverse)
library(highcharter)
options(highcharter.theme = hc_theme_smpl())

n <- 50
set.seed(123)
noise <- rnorm(n)

phis <- round(seq(-.90, .90, by = .1), 2)

data <- phis %>% 
  map_df(function(ar){
    if(ar != 0)
      y <- arima.sim(n = n, list(ar = ar), innov = noise, start.innov = 0, n.start = 1)
    else
      y <- noise
    data_frame(index = seq(1, n) - 1, par = ar, y = as.vector(y))
  })
data

dmotion <- data %>% 
  select(index, y) %>% 
  group_by(index) %>% 
  nest() %>% 
  mutate(data = map(data, pull, 1)) %>% 
  rename(sequence = data)

limit <- data %>% 
  pull(y) %>% 
  abs() %>% 
  max() %>% 
  ceiling()

highchart() %>% 
  hc_add_series(data = dmotion, zIndex = 10) %>%
  hc_add_series(data = data, "line", hcaes(index, y, group = par),
                showInLegend = FALSE, color = hex_to_rgba("gray", 0.1),
                enableMouseTracking = FALSE) %>% 
  hc_yAxis(min = -limit, max = limit) %>% 
  hc_motion(labels = str_pad(phis, 6), updateInterval = 5,
            magnet = list(step = 0.05))


dacf <- data %>% 
  group_by(name = par) %>% 
  do(data = as.vector(acf(.$y)$acf)) %>% 
  mutate(color = hex_to_rgba("gray", 0.2))

highchart() %>% 
  hc_plotOptions(series = list(showInLegend = FALSE)) %>% 
  hc_yAxis(min = -1, max = 1) %>% 
  hc_add_series_list(dacf)
