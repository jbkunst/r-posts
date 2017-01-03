# packages ----------------------------------------------------------------
rm(list = ls())
library(dplyr)
library(tidyr)
library(rvest)
library(stringr)
library(highcharter)
library(lubridate)
library(ggmap)
library(purrr)
options(highcharter.debug = TRUE)



# data --------------------------------------------------------------------
html <- read_html("https://en.wikipedia.org/wiki/U2_360%C2%B0_Tour")

df <- html_table(html, fill = TRUE)[[2]] 
df <- tbl_df(df)

names(df) <- str_replace(str_to_lower(names(df)), " ", "_")

Sys.setlocale("LC_TIME","English")

df <- df %>% 
  mutate(leg = ifelse(str_detect(date, "Leg "), date, NA)) %>% 
  fill(leg) %>% 
  filter(!str_detect(date, "Leg "),
         date != "TOTAL") %>% 
  mutate(attendance2 = str_extract(attendance, ".* "),
         attendance2 = str_replace_all(attendance2, ",| |/", ""),
         attendance2 = as.numeric(attendance2),
         revenue2 =  str_replace_all(revenue, ",|\\$", ""),
         revenue2 = as.numeric(revenue2),
         revenue2 = coalesce(revenue2, 0),
         date2 = as.Date(date, format = "%d %B %Y"),
         ym = date2 - day(date2) + days(1),
         leg = str_replace(leg, "\\[\\d+\\]\\[\\d+\\]", ""))

glimpse(df)

dfym <- df %>% 
  group_by(leg, ym, country, city, venue) %>% 
  summarise(concerts = n(),
            attendance = first(attendance2),
            revenue = first(revenue2)) %>% 
  mutate(location = paste0(country, ", ", city),
         z = revenue) %>% 
  ungroup()

gcodes <- map(dfym$location, geocode)
gcodes <- map_df(gcodes, as_data_frame)

dfym <- bind_cols(dfym, gcodes)

glimpse(dfym)



# first chart -------------------------------------------------------------
world <- hcmap(nullColor = "#424242", borderColor = "gray") %>% 
  hc_chart(backgroundColor = "#161C20") %>% 
  hc_plotOptions(series = list(showInLegend = FALSE))

world

world %>% 
  hc_add_series(data = dfym, type = "mapbubble", name = "Concerts",
                maxSize = "2%", color = "white",
                tooltip = list(valueDecimals = 0,
                               valuePrefix = "$",
                               valueSuffix = " USD")
                )




# motion ------------------------------------------------------------------
# http://jsfiddle.net/gh/get/jquery/1.9.1/larsac07/Motion-Highcharts-Plugin/tree/master/demos/map-australia-bubbles-demo/
dateseq <- seq(min(dfym$ym), max(dfym$ym), by = "month")

sequences <- map2(dfym$ym, dfym$z, function(x, y){ ifelse(x > dateseq, 0, y)})

dfym <- mutate(dfym, sequence = sequences)
dfym$color <- NULL

world %>% 
  hc_add_series(data = dfym, type = "mapbubble", name = "Concerts",
                color = "white", minSize = 0, maxSize = 15, animation = FALSE,
                tooltip = list(valueDecimals = 0, valuePrefix = "$", valueSuffix = " USD")) %>% 
  hc_motion(enabled = TRUE, series = 1, labels = dateseq,  updateInterval = 0.01,
            magnet = list(round = 'round', step = 0.001))
