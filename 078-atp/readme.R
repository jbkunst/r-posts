library(tidyverse)
library(stringr)
library(rvest)
library(lubridate)
library(highcharter)
library(forcats)

names <- read_html("http://www.tennis-x.com/stats/atprankhist.shtml") %>% 
  html_table(fill = TRUE) %>% 
  .[[4]] %>% 
  select(X1) %>% 
  filter(str_detect(X1, "\\([A-Z]{3}\\)")) %>% 
  mutate(
    X1 = str_replace(X1, "\\([A-Z]{3}\\)", ""),
    X1 = str_trim(X1)
    ) %>% 
  pull(X1)

get_ranking_url <- function(name = "marcelo rios") {
  
  message(name)
  
  url <- sprintf("https://www.google.com/search?q=atpworldtour+%s", str_replace_all(name, "\\s+", "+"))
  
  read_html(url) %>% 
    html_node("#center_col") %>% 
    html_node("h3.r") %>%
    html_node("a") %>% 
    html_attr("href") %>% 
    str_extract("http.*overview&") %>% 
    str_sub(end = -2) %>% 
    str_replace("overview","rankings-history")
  
  
}

get_history <- function(url = "http://www.atpworldtour.com/en/players/john-mcenroe/m047/rankings-history")  {
  
  message(url)
  
  read_html(url) %>% 
    html_table() %>% 
    .[[2]] %>% 
    tbl_df() %>% 
    set_names(str_to_lower(names(.))) %>% 
    filter(singles != "0") %>% 
    select(-doubles) %>% 
    mutate(
      date = ymd(date),
      singles = str_replace(singles, "T", ""),
      singles = as.numeric(singles)
      ) 
  
}
  
data <- names %>% 
  map(get_ranking_url) %>% 
  set_names(names) %>% 
  map_df(get_history, .id = "player")

count(data, player, sort = TRUE)

names <- data %>% 
  filter(singles == 1) %>% 
  arrange(desc(date)) %>%
  # arrange(date) %>% 
  distinct(player) %>% 
  pull(player) 
  
data <- mutate(data, player = factor(player, levels = names))


series <- data %>% 
  select(date, everything()) %>% 
  mutate(player = as.numeric(player), date = as.character(date)) %>% 
  # filter(player %in% c(1:5)) %>% 
  list_parse2()

# http://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/demo/heatmap-canvas/

highchart() %>% 
  hc_chart(type = "heatmap") %>% 
  hc_xAxis(type = "datetime") %>% 
  hc_add_series(
    data = series,
    borderWidth = 0,
    nullColor = '#EFEFEF'
  ) %>% 
  hc_tooltip(
    headerFormat =  'Temperature<br/>',
    pointFormat = '{point.x:%e %b, %Y} {point.y}:00: <b>{point.value} ℃</b>'
  ) %>% 
  hc_colorAxis(reversed = TRUE)
  


