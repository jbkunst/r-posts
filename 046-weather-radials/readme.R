rm(list = ls())
library("readr")
library("highcharter")
library("stringr")
library("lubridate")

df <- read_csv("http://bl.ocks.org/bricedev/raw/458a01917183d98dff3c/sf.csv")

names(df) <- names(df) %>% 
  str_to_lower() %>% 
  str_replace("\\s+", "_")

df <- df %>% 
  mutate(id = seq(nrow(df)),
         date2 = as.Date(ymd(date)),
         tmstmp = datetime_to_timestamp(date2),
         month = month(ymd(date)))

dsmax <- df %>% 
  mutate(color = colorize_vector(mean_temperaturec, "D")) %>% 
  select(x = tmstmp,
         y = max_temperaturec,
         name = date,
         color,
         mint = min_temperaturec) %>% 
  list.parse3()
 
dsmin <- df %>% 
  select(x = tmstmp, y = max_temperaturec) %>% 
  list.parse3()


# http://www.weather-radials.com/

highchart() %>% 
  hc_chart(
    type = "column",
    polar = FALSE
    ) %>%
  hc_plotOptions(
    series = list(
      stacking = "normal",
      showInLegend = FALSE
      )
    ) %>% 
  hc_xAxis(
    type = "datetime",
    tickInterval = 30 * 24 * 3600 * 1000,
    labels = list(format = "{value: %b}")
  ) %>% 
  hc_yAxis(
    min = 0,
    labels = list(format = "{value}°C")
  ) %>% 
  hc_add_series(
    data = dsmax
  ) %>% 
  hc_add_series(
    data = dsmin,
    enableMouseTracking = FALSE,
    color = "transparent"
    ) %>% 
  hc_add_theme(
    hc_theme_smpl(
      chart = list(
        style = list(
          fontFamily = "Lato"
          )
        )
      )
    )
  
