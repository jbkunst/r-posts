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
knitr::opts_chunk$set(message=FALSE, warning=FALSE)

#'
library("dplyr")
library("rvest")
library("magrittr")

url <- "http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_base_stats_(Generation_VI-present)"

df <- read_html(url) %>% 
  html_node("table.sortable") %>% 
  html_table() 

names(df) <- c("n", "icon", "pokemon", "hp", "attack", "defense",
               "special_attack", "special_defense", "speed", 
               "total", "average")

df <-  tbl_df(df) %>% select(-icon)

url_icon <- read_html(url) %>% 
  html_nodes("table.sortable img") %>% 
  html_attr("src")

url_detail <- read_html(url) %>% 
  html_nodes("table.sortable span a") %>% 
  html_attr("href") %>% 
  paste0("http://bulbapedia.bulbagarden.net", .)

df <- df %>% 
  mutate(icon = url_icon, url = url_detail)

purrr::map_df(url_detail, function(urlp){
  urlp <- sample(url_detail, size = 1)
  read_html(urlp) %>% 
    html_node("table.sortable") %>% 
    html_table() 
  
  
})