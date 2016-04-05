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
library("ggplot2")
library("ggalt")
library("ggthemes")
library("readxl")
library("dplyr")
library("viridis")
library("stringr")
library("grid")
library("lubridate")
library("gridExtra")
library("showtext")
library("jbkmisc")
blog_setup()

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

drones 

try(x <- Sys.setlocale("LC_TIME", "en_US.UTF-8"))
try(x <- Sys.setlocale("LC_TIME", "English"))

drones <- drones %>% 
  mutate(year = format(ts, "%Y"),
         year_mon = format(ts, "%Y%m"),
         ymd = as.Date(ts), 
         yw = format(ts, "%Y%V"),
         hour = as.numeric(format(ts, "%H")),
         day = wday(ts, label = TRUE, abbr = FALSE)) %>% 
  filter(!is.na(day))

drones$hr2 <- drones$ts %>% format("%H:%M:%S") %>% stringr::str_pad(8, side = "left", pad = "0") %>% hms()
drones 


hoursfmt <- function(x = c(1:24)) {
  x %>% 
    str_pad(2, side = "left", pad = "0") %>% 
    paste0(":00")
}


viridis(10)
col <- "#3E4A89"
col <- "#35B779"


theme_set(theme_jbk() +
            theme(plot.background=element_rect(fill="#2D2D2D", colour="#2D2D2D"),
                  text = element_text(colour = "gray60"))
          )


gg1 <- drones %>% 
  group_by(hour) %>% 
  summarise(n = n()) %>% 
  ggplot() +
  geom_bar(aes(hour, n), fill = col, stat = "identity") +
  scale_x_continuous(labels = hoursfmt, breaks = c(0, 6, 12, 18, 23)) +
  xlab(NULL) + ylab(NULL) +  
  theme(panel.grid = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none")
gg1

gg2 <- ggplot(drones, aes(x = ts, y = hour)) + 
  geom_point(alpha = 0.6) + 
  geom_smooth(color = col)


gg2 <- drones %>% 
  count(hour) %>% 
  mutate(ymin = 0.5, ymax = 1) %>% 
  rbind(data_frame(hour = 24, n = 0, ymin = 0.5, ymax = 0.5)) %>% 
  ggplot() +
  geom_linerange(aes(x = hour,  color = n, ymin = ymin, ymax = ymax), size = 7) +
  scale_x_continuous(labels = hoursfmt, breaks = c(0, 3, 6, 9, 12, 15, 18, 21)) +
  scale_color_viridis() + 
  coord_polar() + 
  xlab(NULL) + ylim(-1, 1) +
  theme(panel.grid = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none")

gg3 <- drones %>% 
  group_by(day, hour) %>% 
  summarise(n = n()) %>% 
  ggplot() +
  geom_tile(aes(hour, day, fill = n)) +
  scale_fill_viridis() +
  scale_x_continuous(labels = hoursfmt, breaks = c(0, 6, 12, 18, 23)) +
  xlab(NULL) + ylab(NULL) + 
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.position = "none")
gg3

gg4 <- drones %>% 
  group_by(day) %>% 
  summarise(n = n()) %>% 
  ggplot() +
  geom_bar(aes(day, n), fill = col, stat = "identity") +
  coord_flip() + xlab(NULL) + ylab(NULL) +
  theme(panel.grid = element_blank(),
        axis.text.x = element_blank(),
        legend.position = "none")
gg4



grid.arrange(gg1, gg2, gg3, gg4, layout_matrix = rbind(c(1,1,2),c(1,1,2),c(3,3,4), c(3,3,4)))

grid.arrange(gg1, gg2, gg3, gg4 + scale_y_reverse(), layout_matrix = rbind(c(2,1,1),c(4,3,3), c(4,3,3)))

