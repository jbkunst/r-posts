#' ---
#' title: "A brief look to Hollywood's 100 Favorite TV Shows"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---
# http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm
#+ warning=FALSE, message=FALSE
library("rvest")
library("plyr")
library("dplyr")
library("stringr")

library("ggplot2")
library("ggthemes")
library("viridis")

#' http://www.hollywoodreporter.com/
#' 

url <- "http://www.hollywoodreporter.com/lists/best-tv-shows-ever-top-819499/item/desperate-housewives-hollywoods-100-favorite-820451"

items <- html(url) %>% 
  html_nodes(".list--ordered__item")

length(items) == 100 # Yay!


data <- ldply(items, function(item){
  # item <- sample(items, size = 1)[[1]]
  # item <- items[[45]]

  name <- item %>% html_node(".list-item__title") %>% html_text()
  
  info <- item %>% html_node(".list-item__deck") %>% html_text()
  
  years <- str_extract_all(info, "\\d+") %>% unlist() %>% as.numeric()
  
  company <- str_replace(info, "\\(.*\\)", "") %>% str_trim()
  
  url_image <- item %>% html_node(".list-media__image") %>% html_attr("src")
  
  data_frame(name, from = years[1], to = years[2], company, url_image)
  
})

data <- tbl_df(data) %>% 
  mutate(place = rev(seq(100)))

data

which(data$name == "The Wonder Years")

