library(tidyverse)
library(rvest)
library(lubridate)
Sys.setlocale("LC_TIME","English")



# DATA --------------------------------------------------------------------
html <- read_html("https://en.wikipedia.org/wiki/U2_360%C2%B0_Tour")

data <- html_table(html, fill = TRUE)[[2]] 

data <- data %>% 
  tbl_df() %>% 
  rename_all(str_to_lower) %>% 
  rename_all(str_replace_all, "\\s+", "_")

glimpse(data)

# remove intermediate leg 
data <- data %>% 
  mutate(leg = ifelse(str_detect(date, "Leg "), date, NA)) %>% 
  fill(leg) %>% 
  filter(!str_detect(date, "Leg "), date != "TOTAL")


data <- data %>% 
  mutate(
    attendance2 = str_extract(attendance, ".* "),
    attendance2 = str_replace_all(attendance2, ",| |/", ""),
    attendance2 = as.numeric(attendance2),
    revenue2 =  str_replace_all(revenue, ",|\\$", ""),
    revenue2 = as.numeric(revenue2),
    revenue2 = coalesce(revenue2, 0),
    date2 = as.Date(date, format = "%d %B %Y"),
    ym = date2 - day(date2) + days(1),
    leg = str_replace(leg, "\\[\\d+\\]\\[\\d+\\]", "")
    )

glimpse(data)

data <- data %>% 
  select(
    leg, date = date2, city, country, venue, 
    opening_act, attendance = attendance2,
    revenue = revenue2, ym
    )

dfym <- data %>% 
  group_by(leg, ym, country, city, venue) %>% 
  summarise(
    concerts = n(),
    attendance = sum(attendance),
    revenue = sum(revenue)
    ) %>% 
  mutate(
    location = paste0(country, ", ", city),
    z = revenue
    ) %>% 
  ungroup()



# GEOCODE -----------------------------------------------------------------
library(ggmap)

geocode("United States, Minneapolis", source = "dsk")


library(furrr)

plan(multiprocess)


gcodes <- dfym %>% 
  pull(location) %>% 
  future_map(geocode, source = "dsk") %>% 
  map_df(as_tibble)


dfym <- bind_cols(dfym, gcodes)

glimpse(dfym)


# first chart -------------------------------------------------------------
library(highcharter)

# library(proj4)
# robinson <- project(cbind(dfym$lon, dfym$lat), 
#                     proj = "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
# 
# dfym <- dfym %>% 
#   mutate(
#     lon = robinson[,1],
#     lat = robinson[,2]
#   )

world <- hcmap(
  # "custom/world-robinson-lowres",
  nullColor = "#424242",
  borderColor = "gray"
  ) %>% 
  hc_chart(backgroundColor = "#161C20") %>% 
  hc_plotOptions(series = list(showInLegend = FALSE))

world

world %>% 
  hc_add_series(
    data = dfym,
    type = "mapbubble",
    mapping = hcaes(x = lon, y = lat, z = z, name = location),
    name = "Concerts",
    maxSize = "2%",
    color = "white",
    tooltip = list(
      valueDecimals = 0,
      valuePrefix = "$",
      valueSuffix = " USD"
      )
  )




# motion ------------------------------------------------------------------
# http://jsfiddle.net/gh/get/jquery/1.9.1/larsac07/Motion-Highcharts-Plugin/tree/master/demos/map-australia-bubbles-demo/
dateseq <- seq(min(dfym$ym), max(dfym$ym), by = "month")

sequences <- map2(dfym$ym, dfym$z, function(x, y){ ifelse(x > dateseq, 0, y)})

cols <- viridis::inferno(12, begin = 0.2)
scales::show_col(cols)  

dfym <- mutate(dfym, sequence = sequences, color = colorize(revenue, cols))

dateslabels <- format(dateseq, "%Y/%m")

world %>% 
  hc_add_series(data = dfym, type = "mapbubble", name = "Concerts", 
                minSize = 0, maxSize = 15, animation = FALSE,
                tooltip = list(valueDecimals = 0, valuePrefix = "$", valueSuffix = " USD")) %>% 
  hc_motion(enabled = TRUE, series = 1, labels = dateslabels,
            loop = TRUE, autoPlay = TRUE, 
            updateInterval = 1000, magnet = list(step =  1))

