#' ---
#' title: "Watching Forrest Gump through the Data"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.showtext = TRUE, dev = "CairoPNG")

#' Packages and options
library("dplyr")
library("rvest")
library("stringr")
library("purrr")
library("lubridate")
library("highcharter")

options(highcharter.theme = hc_theme_smpl())

#'
#' > I'm not a smart man but I (*think to*) know what data is.
#' > <cite>-- Me</cite>
#' 
#' 
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
script <- read_html("http://www.imsdb.com/scripts/Forrest-Gump.html") %>% 
  html_nodes(".scrtext")

script <- as.vector(as.character(script))
script <- unlist(str_split(script, "\n"))

data <- data_frame(line = script) %>% 
  mutate(
    scene = str_detect(line, "EXT.|INT."),
    scene = cumsum(scene),
    character = str_detect(line, "<b>\\s{37}"),
    dialog_srt = character,
    dialog_end = str_detect(line, "^$")
  )

