#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---
#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "",
                      fig.showtext = TRUE, dev = "CairoPNG")
setwd("~/dev/r-posts/070-gapminder")
#'
#'
#'
library(readxl)
library(tidyr)
library(dplyr)
library(janitor)
library(stringr)
library(purrr)
library(ggplot2)
library(highcharter)

dgdp <- read_excel("data/indicator gapminder gdp_per_capita_ppp.xlsx")
dpop <- read_excel("data/indicator gapminder population.xlsx")
dlex <- read_excel("data/indicator life_expectancy_at_birth.xlsx")

dgdpg <- dgdp %>% 
  clean_names() %>% 
  gather(year, gdp, -gdp_per_capita) %>% 
  rename(country = gdp_per_capita, gdp_per_capita = gdp) %>% 
  mutate(year = str_extract(year, "\\d{4}"),
         year = as.numeric(year)) %>% 
  filter(!is.na(country))

dpopg <- dpop %>% 
  clean_names() %>% 
  gather(year, pop, -total_population) %>% 
  rename(country = total_population, total_population = pop) %>% 
  mutate(year = str_extract(year, "\\d{4}"),
         year = as.numeric(year)) %>% 
  filter(!is.na(country))

dlexg <- dlex %>% 
  clean_names() %>% 
  gather(year, lex, -life_expectancy) %>% 
  rename(country = life_expectancy, life_expectancy = lex) %>% 
  mutate(year = str_extract(year, "\\d{4}"),
         year = as.numeric(year)) %>% 
  filter(!is.na(country))

data <- dlexg %>% 
  full_join(dgdpg) %>% 
  full_join(dpopg) %>% 
  arrange(year, country)

data(gapminder, continent_colors, package = "gapminder")

data <- gapminder %>% 
  distinct(country, continent) %>% 
  dmap_if(is.factor, as.character) %>% 
  left_join(data, .) %>% 
  filter(!is.na(continent))

data <- data %>% 
  group_by(country) %>% 
  fill(life_expectancy, gdp_per_capita, total_population) %>% 
  fill(life_expectancy, gdp_per_capita, total_population, .direction = "up")

data %>%
  gather(key, value, -country, -continent, -year) %>%
  group_by(country, key) %>%
  summarise(nas = sum(is.na(value))) %>% 
  arrange(desc(nas))

data <- filter(data, country != "Reunion")
# data %>% 
#   filter(country == "Afghanistan") %>% 
#   View()

# data for motion ---------------------------------------------------------
data <- mutate(data, total_population = round(total_population/1e6))
data <- filter(data, year >= 1950)

data_strt <- distinct(data, country, continent, .keep_all = TRUE) %>% 
  mutate(x = gdp_per_capita, y = life_expectancy, z = total_population)

data_seqc <- data %>% 
  arrange(country, year) %>% 
  group_by(country) %>% 
  do(sequence = list_parse2(select(., x = gdp_per_capita, y = life_expectancy, z = total_population)))

data_motion <- left_join(data_strt, data_seqc)  
data_motion

data %>% 
  ungroup() %>% 
  summarise_if(is.numeric, funs(min, max)) %>% 
  gather(key, value) %>% 
  arrange(key)

# highchart() %>% 
#   hc_add_series(data = data_motion, type = "bubble",
#                 minSize = 5, maxSize = 50, marker = list(fillOpacity = .75)) %>% 
#   hc_motion(enabled = TRUE, series = 0, labels = unique(data$year),
#             loop = TRUE, autoPlay = FALSE, startIndex = 0,
#             updateInterval = 1,
#             magnet = list(step = 0.05)) %>% 
#   hc_plotOptions(series = list(showInLegend = TRUE)) %>% 
#   hc_xAxis(type = "logarithmic", min = 100, max = 120000) %>% 
#   hc_yAxis(min = 0, max = 85) %>% 
#   hc_add_theme(hc_theme_smpl()) %>% 
#   hc_add_dependency_fa()

data_motion2 <- data_motion %>% 
  group_by(continent) %>% 
  do(data = list_parse(select(., -continent))) %>% 
  rename(name = continent)
  

options(highcharter.debug = TRUE)

highchart() %>% 
  hc_chart(type = "bubble") %>% 
  hc_plotOptions(bubble = list(minSize = 5, maxSize = 50,
                               marker = list(fillOpacity = .75))) %>% 
  hc_add_series_list(data_motion2) %>% 
  hc_motion(enabled = TRUE, series = seq(nrow(data_motion2)) - 1,
            labels = unique(data$year),
            loop = FALSE, autoPlay = FALSE, startIndex = 0,
            updateInterval = 1, magnet = list(step = 0.05)) %>% 
  hc_xAxis(type = "logarithmic", min = 100, max = 120000,
           title = list(text = "GPD per capita")) %>% 
  hc_yAxis(min = 0, max = 85, title = list(text = "Life Expectancy")) %>% 
  # hc_add_theme(hc_theme_monokai())
  # hc_add_theme(hc_theme_smpl())
  # hc_add_theme(hc_theme_db())
  # hc_add_theme(hc_theme_economist())
  # hc_add_theme(hc_theme_538())

# highcharts_demo()



