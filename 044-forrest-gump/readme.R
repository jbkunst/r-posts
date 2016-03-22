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
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")
library("dplyr")
library("rvest")
library("stringr")
library("purrr")
library("jbkmisc")
library("highcharter")
blog_setup()

#'
#' > I'm not a man but I (*think to*) know what data is
#' 
#' 

urltl <- "http://www.timetoast.com/timelines/forrest-gump-timeline-of-events-and-major-figures"

df <- read_html(urltl) %>% 
  html_nodes("table tr") %>% 
  .[-c(1, length(.) - 1, length(.))] %>% 
  map_df(function(x){
    # x <- sample(read_html(urltl) %>%  html_nodes("table tr"), size = 1)[[1]]
    data_frame(
      id = x %>% html_node("img") %>% html_attr("alt") %>% tolower(),
      name = x %>% html_node("b") %>% html_text(),
      time = x %>% html_node("time") %>% html_attr("datetime"),
      imgurl = x %>% html_node("img") %>% html_attr("src") %>% str_replace("//", "")  
    )
  })

df


