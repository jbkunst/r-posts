rm(list = ls())
library("httr")
library("plyr")
library("dplyr")
library("purrr")
library("igraph")
library("ggplot2")



site <- "stackoverflow"
tag <- "r"
pages <- seq(30)

api_url <- "https://api.stackexchange.com/2.2/questions"


qlst <- pages %>% 
  map(function(p){
    data <- api_url %>% 
      GET(query = list(site = site, tagged = tag, page = p)) %>% 
      content()
    data$items
  }) %>% 
  unlist(recursive = FALSE)

qdf <- ldply(qlst, function(x){
  # x <- sample(qlst, size = 1)[[1]]
  tags <- x$tags %>% unlist()
  if (length(tags) > 1) {
    data_frame(question_tag = setdiff(tags, tag),
               question_id = x$question_id)  
  }
}, .progress="win")

qdf <- tbl_df(qdf)

qdf %>% count(question_tag) %>% arrange(n)
