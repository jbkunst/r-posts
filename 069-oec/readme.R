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
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "")
#+

# packages ----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(jbkmisc)
library(tidyr)
library(broom)
library(viridis)
theme_set(theme_jbk())

# data --------------------------------------------------------------------
# dprod <- read_csv("http://atlas.media.mit.edu/en/rankings/hs92/?download=true")
# names(dprod) <- tolower(names(dprod))
# dprod

data <- read_csv("http://atlas.media.mit.edu/en/rankings/country/?download=true")
names(data) <- tolower(names(data))
data

data <- countrycode::countrycode_data %>% 
  tbl_df() %>% 
  select(id = iso3c, continent) %>% 
  mutate(id= tolower(id)) %>% 
  right_join(data, by = "id") 

data

# explore -----------------------------------------------------------------
data %>% 
  count(year) %>% 
  ggplot() +
  geom_line(aes(year, n)) + 
  scale_y_continuous(limits = c(0, NA))

countries_to_study <- data %>% 
  group_by(country) %>% 
  summarise(
    n = n(),
    year_min = min(year)
    ) %>% 
  arrange(n) %>% 
  mutate(pcum = ecdf(n)(n))

ggplot(countries_to_study) + 
  geom_histogram(aes(n))

ggplot(countries_to_study) + 
  geom_line(aes(n, pcum))

countries_to_study <- filter(countries_to_study, pcum > .5)

data <- semi_join(data, countries_to_study)

data %>% 
  count(country) %>% 
  count(n)

ggplot(data) + 
  geom_bar(aes(continent, fill = continent)) + 
  scale_fill_viridis(discrete = TRUE)

ggplot(data) + 
  geom_smooth(aes(year, eci, group = continent, color = continent), se = FALSE) +
  scale_color_viridis(discrete = TRUE)
  
ggplot(data, aes(year, eci)) + 
  geom_line(aes(group = country, color = continent), alpha = .4) +
  geom_smooth(aes(year, eci, group = continent, color = continent), se = FALSE) +
  facet_wrap(~ continent) +
  scale_color_viridis(discrete = TRUE) 

filter(data, eci == min(eci))


data_ae <- data %>% 
  select(id, continent, year, eci) %>% 
  mutate(year = paste0("y", year)) %>% 
  spread(year, eci) %>% 
  arrange(id)
data_ae


