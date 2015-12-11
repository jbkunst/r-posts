#' ---
#' title: "Leaflet in SO"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    theme: journal
#'    toc: false
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
library("dplyr")
library("readr")
library("stringr")
library("ggplot2")
library("showtext")
library("printr")

knitr::opts_chunk$set(error = TRUE, warning = FALSE,
                      cache = FALSE, fig.showtext = TRUE,
                      dev = "CairoPNG", fig.width = 8)

font.add.google("Lato", "myfont")
showtext.auto()

theme_set(theme_minimal(base_size = 13, base_family = "myfont") +
            theme(legend.position = "none",
                  text = element_text(colour = "#616161")))

#' Data from http://data.stackexchange.com/stackoverflow/query/407411/leafet
data <- read_csv("http://data.stackexchange.com/stackoverflow/csv/521113")
head(data)

data <- data %>%
  filter(str_detect(CreationDate, "^2015")) %>% 
  mutate(leafet_with_r = str_detect(Tags, "<r>|<shiny>|<rstudio>"),
         leafet_with_angular = str_detect(Tags, "<angular"),
         leafet_with = "Other",
         leafet_with = ifelse(leafet_with_r, "R", leafet_with),
         leafet_with = ifelse(leafet_with_angular, "Angular", leafet_with),
         leafet_with = ifelse(leafet_with_r + leafet_with_angular == 2, "Both", leafet_with))

data %>% count(leafet_with)


ggplot(data %>% count(leafet_with)) + 
  geom_bar(aes(leafet_with, n), stat = "identity",
           fill = "#1FA67A", width = 0.5)
                              
