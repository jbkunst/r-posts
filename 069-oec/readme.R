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
  geom_line(aes(year, eci, group = country), alpha = 0.2)

filter(data, eci == min(eci))

ggplot(data) + 
  geom_density(aes(eci), fill = "gray90") + 
  facet_wrap(~  year) + 
  theme(
    panel.grid.major = element_line(colour = "transparent"),
    panel.grid.minor = element_line(colour = "transparent")
  )

data %>% 
  group_by(year) %>% 
  mutate(ecis = scale(eci)) %>%
  ungroup() %>% 
  group_by(year) %>% 
  do(tidy(summary(.$ecis))) %>%
  ungroup() %>% 
  gather(key, value, -year) %>% 
  ggplot() + 
  geom_smooth(aes(year, value, group = key, color = key), se = FALSE) + 
  scale_color_viridis(discrete = TRUE)


