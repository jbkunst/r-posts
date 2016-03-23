rm(list = ls())
library("dplyr")
library("readr")
library("highcharter")
library("stringr")
library("lubridate")

df <- read_csv("http://bl.ocks.org/bricedev/raw/458a01917183d98dff3c/sf.csv")

head(df)

names(df) <- names(df) %>% 
  str_to_lower() %>% 
  str_replace("\\s+", "_")

df <- df %>% 
  mutate(id = seq(nrow(df)),
         date2 = as.Date(ymd(date)),
         tmstmp = datetime_to_timestamp(date2),
         month = month(ymd(date)))

dsmax <- df %>%
  select(x = tmstmp,
         y = max_temperaturec) %>% 
  list.parse3()
 
dsmin <- df %>% 
  select(x = tmstmp, y = min_temperaturec) %>% 
  list.parse3()


# http://www.weather-radials.com/

hc <- highchart() %>% 
  hc_chart(
    type = "line"
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
    data = dsmax, name = "max"
  ) %>% 
  hc_add_series(
    data = dsmin, name = "min"
    ) %>% 
  hc_add_theme(
    hc_theme_smpl()
    )

hc


hc <- hc %>% 
  hc_chart(
    type = "column"
    ) %>% 
  hc_plotOptions(
    series = list(
      stacking = "normal"
    )
  )

hc


dsmax <- df %>% 
  mutate(color = colorize_vector(mean_temperaturec, "A"),
         y = max_temperaturec - min_temperaturec) %>% 
  select(x = tmstmp,
         y,
         name = date,
         color,
         mean = mean_temperaturec,
         max = max_temperaturec,
         min = min_temperaturec) %>% 
  list.parse3()



x <- c("Min", "Mean", "Max")
y <- sprintf("{point.%s}", tolower(x))
tltip <- tooltip_table(x, y)

hc <- highchart() %>% 
  hc_chart(
    type = "column",
    polar = TRUE
  ) %>%
  hc_plotOptions(
    series = list(
      stacking = "normal",
      showInLegend = FALSE
    )
  ) %>% 
  hc_xAxis(
    gridLineWidth = 0.5,
    type = "datetime",
    tickInterval = 30 * 24 * 3600 * 1000,
    labels = list(format = "{value: %b}")
  ) %>% 
  hc_yAxis(
    max = 30,
    min = -10,
    labels = list(format = "{value}°C"),
    showFirstLabel = FALSE
    ) %>% 
  hc_add_series(
    data = dsmax
  ) %>% 
  hc_add_series(
    data = dsmin,
    color = "transparent",
    enableMouseTracking = FALSE
  ) %>% 
  hc_add_theme(
    hc_theme_smpl()
  ) %>% 
  hc_tooltip(
    useHTML = TRUE,
    headerFormat = as.character(tags$small("{point.x:%d %B, %Y}")),
    pointFormat = tltip
  )

hc

hc %>% 
  hc_chart(
    polar = FALSE
  ) %>% 
  hc_yAxis(
    min = 0,
    showFirstLabel = TRUE
  )
