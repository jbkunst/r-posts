library(dplyr)
library(tidyr)
library(rvest)
library(stringr)
library(highcharter)
library(lubridate)
library(ggmap)
library(purrr)

options(highcharter.debug = TRUE)


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
         ym = date2 - day(date2) + days(1))

df

dfym <- df %>% 
  group_by(leg, ym, country, city, venue) %>% 
  summarise(concerts = n(),
            attendance = first(attendance2),
            revenue = first(revenue2)) %>% 
  mutate(location = paste0(country, ", ", city))

gcodes <- map(dfym$location, geocode)
gcodes <- map_df(gcodes, as_data_frame)

dfym <- bind_cols(dfym, gcodes)

dfym2 <- dfym %>% 
  select(name = location, lat, lon, z = revenue)

# cities <- data_frame(
#   name = c("London", "Birmingham", "Glasgow", "Liverpool"),
#   lat = c(51.507222, 52.483056,  55.858, 53.4),
#   lon = c(-0.1275, -1.893611, -4.259, -3),
#   z = c(1, 2, 3, 2)
# )

glimpse(dfym2)

hcmap(nullColor = "#262C20", borderColor = "gray") %>% 
  hc_chart(backgroundColor = "#161C20") %>% 
  hc_add_series(data = dfym2, type = "mapbubble", name = "Concerts", maxSize = '2%', color = "white",
                tooltip = list(valueDecimals = 0, valuePrefix = "$", valueSuffix = " USD")) %>% 
  hc_mapNavigation(enabled = TRUE) %>% 
  hc_plotOptions(series = list(showInLegend = FALSE))
