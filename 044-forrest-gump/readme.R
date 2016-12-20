#' ---
#' title: "Watching Forrest Gump through the Data"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE)
library(jbkmisc)

#' Packages and options
library(dplyr)
library(rvest)
library(stringr)
library(purrr)
library(tidyr)
library(highcharter)



options(highcharter.theme = hc_theme_smpl())

#'
#' > I'm not a smart man but I (*think to*) know what data is.
#' > <cite>-- Me</cite>
#' 

script <- read_html("http://www.imsdb.com/scripts/Forrest-Gump.html") %>% 
  html_nodes(".scrtext")

script <- as.vector(as.character(script))
script <- unlist(str_split(script, "\n"))

script[100:120]

data <- data_frame(
  id_line = seq_along(script),
  line = script) %>% 
  mutate(
    line_is_scen = str_detect(line, "EXT.|INT."),
    line_is_char = str_detect(line, "<b>") & !line_is_scen,
    line_is_dial = str_detect(line, "^\\s{25}|</b>\\s{25}"),
    line_is_narr = str_detect(line, "^\\s{15}") & !line_is_dial &! line_is_scen
  ) %>% 
  dmap_if(is.logical, as.numeric) %>% 
  dmap_if(is.character, str_trim) 

data %>% 
  count(line_is_scen, line_is_char, line_is_dial, line_is_narr,
        sum = line_is_scen + line_is_char + line_is_dial  + line_is_narr)

data <- data %>% 
  mutate(line_clean = str_replace_all(line, "<b>|</b>|EXT.|INT." , ""),
         scene = ifelse(line_is_scen, line_clean, NA),
         character = ifelse(line_is_char, line_clean, NA),
         character = ifelse(line_is_narr, "NARRATIVE", character),
         text = ifelse(line_is_dial | line_is_narr, line_clean, NA),
         # full stop
         character = ifelse(is.na(character) & is.na(text), "FS", character)) %>% 
  fill(scene, character) %>% 
  filter(!is.na(scene)) 

data <- select(data, scene, character, text) 


x <- c("a", "a", "a", "b", "b", "c", "c", "a", "b", "b", "c")
y <- c(TRUE, head(x, -1) != tail(x, -1))
z <- cumsum(y)
data_frame(x, y, z)

data <- data %>% 
  mutate(scene_id = !duplicated(scene),
         scene_id = cumsum(scene_id),
         change_char = c(TRUE, head(character, -1) != tail(character, -1)),
         dialog_id = cumsum(change_char),
         text = ifelse(is.na(text), "", text))

data
datdy <- data %>% 
  group_by(scene_id, scene, dialog_id) %>% 
  summarise(
    character = first(character),
    dialog = paste(text, collapse = "")
  ) %>% 
  ungroup() %>% 
  filter(character != "FS") %>% 
  mutate(dialog_id = seq(1, nrow(.)))

datdy

View(count(datdy, character, sort = TRUE))



#' ## A _simple_ timeline
#' 
#' Let's start with e
# urltl <- "http://www.timetoast.com/timelines/forrest-gump-timeline-of-events-and-major-figures"
# 
# df <- read_html(urltl) %>% 
#   html_nodes(".list-timeline__list > li") %>% 
#   map_df(function(x){
#     # x <<- x
#     data_frame(
#       detail = x %>% html_node(".timeline-item__title") %>% html_text() %>% str_trim(),
#       date = x %>% html_node("time") %>% html_attr("datetime"),
#       date_fmt = x %>% html_node("time") %>% html_text(),
#       imgurl =  x %>% html_node("img") %>% html_attr("src") %>% str_replace("//", "")  
#       )
#   })
# 
# df <- df %>% 
#   mutate(date = ymd_hms(date),
#          dt = datetime_to_timestamp(date),
#          y = rep(4:1, length.out = nrow(df))) %>% 
#   arrange(dt)
#   
# df <- df[-1, ]
# 
# glimpse(df)
# 
# hctl <- hchart(df, "point", hcaes(dt, y), name = "FG timeline") %>% 
#   hc_xAxis(type = "datetime", title = list(text = ""),
#            gridLineColor = "transparent") %>% 
#   hc_yAxis(visible = FALSE) %>% 
#   hc_size(height = 200)
# 
# hctl


#' Tooltip
#' 
# tt <- tags$table(height = 100,
#   tags$strong("{point.detail}"),
#   tags$p("{point.date_fmt}"),
#   tags$img(src = "http://{point.imgurl}",
#            style="display: block;margin: 0 auto; height='80px'")
#   )
# 
# cat(as.character(tt))
# 
# hctl <- hctl %>% 
#   hc_tooltip(pointFormat = as.character(tt),
#              headerFormat = "",
#              useHTML = TRUE)
# 
# hctl

#' 