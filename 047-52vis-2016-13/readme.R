#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")
library(ggplot2)
library(ggalt)
library(ggthemes)
library(readxl)
library(dplyr)
library(grid)

URL1 <- "http://www.faa.gov/uas/media/UAS_Sightings_report_21Aug-31Jan.xlsx"
URL2 <- "http://www.faa.gov/uas/media/UASEventsNov2014-Aug2015.xls"

fil1 <- basename(URL1)
fil2 <- basename(URL2)

if (!file.exists(fil1)) download.file(URL1, fil1, mode = "wb")
if (!file.exists(fil2)) download.file(URL2, fil2, mode = "wb")

xl1 <- read_excel(fil1)
xl2 <- read_excel(fil2)

drones <- setNames(bind_rows(xl2[,1:3],
                             xl1[,c(1,3,4)]), 
                   c("ts", "city", "state"))
drones <- mutate(drones, 
                 year = format(ts, "%Y"), 
                 year_mon = format(ts, "%Y%m"), 
                 ymd = as.Date(ts), 
                 yw = format(ts, "%Y%V"))

by_week <- mutate(count(drones, yw), wk = as.Date(sprintf("%s1", yw), "%Y%U%u") - 7)
by_week <- arrange(filter(by_week, wk >= as.Date("2014-11-10")), wk)

gg <- ggplot(by_week, aes(wk, n))
gg <- gg + geom_bar(stat = "identity", fill = "#937206")
gg <- gg + annotate("text", by_week$wk[1], 49, label = "# reports", 
                    hjust = 0, vjust = 1, family = "Cabin-Italic", size = 3)
gg <- gg + scale_x_date(expand = c(0,0))
gg <- gg + scale_y_continuous(expand = c(0,0))
gg <- gg + labs(y = NULL,
                title = "Weekly U.S. UAS (drone) sightings",
                subtitle = "As reported to the Federal Aviation Administration",
                caption = "Data from: http://www.faa.gov/uas/law_enforcement/uas_sighting_reports/")
gg <- gg + theme_minimal()
gg <- gg + theme(axis.title.x = element_text(margin = margin(t = -6)))
gg



library("rvest")
library("stringr")
library("purrr")
library("lubridate")
library("viridis")

str_locate2 <- function(string, pattern) {
  str_locate(string, pattern)[, 1]
}

url <- "https://en.wikipedia.org/wiki/List_of_U.S._states_and_territories_by_population"


statespop <- read_html(url) %>% 
  html_table(fill = TRUE) %>% 
  .[[1]] %>% 
  select(c(3, 4)) %>% 
  tbl_df() %>% 
  setNames(c("state", "pop")) %>% 
  mutate(state = str_sub(state, 2),
         state = ifelse(str_detect(state, " Dakota"), "North Dakota", state),
         state = str_trim(state),
         pop = str_replace_all(pop, "\\,", ""),
         pop = as.numeric(pop))
  

dronesym <- drones %>%
  filter(!is.na(ymd), state != "CANADA") %>% 
  mutate(year_mon = paste0(year_mon, "01"),
         year_mon = ymd(year_mon)) %>% 
  group_by(state, year_mon) %>% 
  summarise(count = n()) %>% 
  ungroup() %>% 
  left_join(statespop, by = "state") %>% 
  mutate(count2 = count/pop * 1000000)


ggplot(dronesym) + 
  geom_tile(aes(year_mon, state, fill = count2)) + 
  scale_fill_viridis() +
  theme_minimal()
