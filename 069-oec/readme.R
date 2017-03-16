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
  geom_line(aes(year, n)) # + scale_y_continuous(limits = c(0, NA))

countries_to_study <- data %>% 
  group_by(country) %>% 
  summarise(year_min = min(year))
  


