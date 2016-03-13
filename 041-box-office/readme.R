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
knitr::opts_chunk$set(message = FALSE, warning = FALSE)
library("dplyr")
library("rvest")
library("purrr")
library("stringr")
library("DT")
library("ggplot2")
library("lubridate")
#'
#'

url <- "http://www.boxofficemojo.com/alltime/domestic.htm"

urls <- paste0(url, sprintf("?page=%s&p=.htm", 1:10))


dfmovie <- map_df(urls, function(x){
  # x <- sample(size = 1, urls)
  urlmovie <- read_html(x) %>% 
    html_nodes("table table tr a") %>%
    html_attr("href") %>% 
    .[str_detect(., "movies")]
  
  read_html(x) %>% 
    html_nodes("table table") %>% 
    html_table(fill = TRUE) %>% 
    .[[4]] %>% 
    tbl_df() %>% 
    .[-1, ] %>% 
    setNames(c("rank", "title", "studio", "gross", "year")) %>% 
    mutate(url_movie = urlmovie)
  
}) 

dfmovie <- dfmovie %>% 
  mutate(year = str_extract(year, "\\d+"),
         year = as.numeric(year),
         have_release = str_detect(url_movie, "releases"),
         box_id = str_extract(url_movie, "id=.*"),
         box_id = str_replace_all(box_id, "^id=|\\.htm$", ""))


datatable(dfmovie)


dfgross <- map_df(dfmovie$box_id, function(x){
  # x <- sample(dfmovie$box_id, size =1)
  message(x)
  
  if(file.exists(sprintf("data/%s.rds", x))) {
    dfgr <- readRDS(sprintf("data/%s.rds", x))
    return(dfgr)
  }
    
  dfgr <- sprintf("http://www.boxofficemojo.com/movies/?page=daily&view=chart&id=%s.htm", x)  %>% 
    read_html() %>% 
    html_nodes("table table table") %>% 
    html_table(fill = TRUE) %>% 
    last() %>% 
    tbl_df()
  
  if (nrow(dfgr) == 1) {
    dfgr <- data_frame(box_id = x)
  } else {
    dfgr <- dfgr %>% 
      .[-1, ] %>% 
      setNames(c("day", "date", "rank", "gross", "pd", "na", "theaters_avg", "na2", "gross_to_date", "day_number")) %>% 
      mutate(box_id = x) %>% 
      filter(!is.na(day_number))
  }
  
  saveRDS(dfgr, file = sprintf("data/%s.rds", x))
  
  dfgr
  
})

save(dfgross, dfmovie, file = "data/data.RData")

dfgross <- dfgross %>% 
  mutate(gross = as.numeric(str_replace_all(gross, "\\$|\\,", "")),
         gross_to_date = as.numeric(str_replace_all(gross_to_date, "\\$|\\,", "")),
         day_number = as.numeric(day_number),
         date2 = str_replace_all(date, "\\t|\\.", ""),
         date2 = as.Date(date2, "%b %d, %Y"),
         decade = year(date2)/100) %>% 
  filter(!is.na(date))


ggplot(dfgross %>% filter(str_detect(box_id, "harrypotter"))) + 
  geom_line(aes(date2, gross_to_date, color = box_id))

ggplot(dfgross %>% filter(str_detect(box_id, "harrypotter"))) + 
  geom_line(aes(day_number, gross_to_date, color = box_id))

ggplot(dfgross %>% filter(year(date2) > 2010)) + 
  geom_line(aes(date2, gross_to_date, fill = box_id))
