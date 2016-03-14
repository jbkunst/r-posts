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
library("directlabels")
library("lubridate")
#'
#'

url <- "http://www.boxofficemojo.com/alltime/domestic.htm"

urls <- paste0(url, sprintf("?page=%s&p=.htm", 1:1))

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

dfmovie2 <- map_df(dfmovie$box_id, function(x){
  # x <- "starwars2"
  # x <- sample(dfmovie$box_id, size =1); 
  message(x)
  
  if (file.exists(sprintf("data/%s-p2.rds", x))) {
    dfm <- readRDS(sprintf("data/%s-p2.rds", x))
    return(dfm)
  }
  
  html <- sprintf("http://www.boxofficemojo.com/movies/?page=main&id=%s.htm", x) %>% 
    read_html()
  
  img_url <- html %>% 
    html_nodes("table table table img") %>% 
    .[[1]] %>% 
    html_attr("src")
  
  tmp <- tempfile(fileext = ".jpg")
  download.file(img_url, tmp, mode = "wb", quiet = TRUE)
  img <- jpeg::readJPEG(tmp)
  imgpltt <- image_palette(img, n = 1, choice = median)
  
  # par(mfrow = c(1, 2))
  # display_image(img)
  # scales::show_col(imgpltt)
  
  dfaux <- html %>% 
    html_nodes("table  table  table") %>% 
    .[[2]] %>% 
    html_table(fill = TRUE) %>% 
    .[-1, 1:2] %>% 
    tbl_df()

  dfm <- data_frame(
    box_id = x,
    distributor = str_replace(dfaux[2, 1], "Distributor: ", ""),
    genre = str_replace(dfaux[3, 1], "Genre: ", ""),
    mpaa_rating = str_replace(dfaux[4, 1], " MPAA Rating: ", ""),
    runtime = str_replace(dfaux[3, 2], " Runtime: ", ""),
    production_budget = str_extract(dfaux[4, 2], "\\d+"),
    img_url = img_url,
    img_main_color = imgpltt
  )
  
  saveRDS(dfm, file = sprintf("data/%s-p2.rds", x))
  
  dfm
    
})

dfmovie <- left_join(dfmovie, dfmovie2, by = "box_id")


dfgross <- map_df(dfmovie$box_id, function(x){
  # x <- sample(dfmovie$box_id, size =1)
  message(x)
  
  if (file.exists(sprintf("data/%s.rds", x))) {
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

try(Sys.setlocale("LC_TIME", "en_US.UTF-8"))
try(Sys.setlocale("LC_TIME", "English"))

dfgross <- dfgross %>% 
  mutate(gross = as.numeric(str_replace_all(gross, "\\$|\\,", "")),
         gross_to_date = as.numeric(str_replace_all(gross_to_date, "\\$|\\,", "")),
         day_number = as.numeric(day_number),
         date2 = str_replace_all(date, "\\t|\\.", ""),
         date2 = as.Date(date2, "%b %d, %Y"),
         decade = year(date2)/100,
         movieserie = str_extract(box_id, "^[A-Za-z]+|\\d{2,3}"),
         serienumber = str_extract(box_id, "\\d$"),
         serienumber = ifelse(is.na(serienumber), 1, serienumber)) %>% 
  filter(!is.na(date))


save(dfgross, dfmovie, file = "data/data.RData")

dfgross

gg <- ggplot(dfgross) + 
  geom_line(aes(date2, gross_to_date, fill = box_id)) 

gg

gg + xlim(as.Date(ymd(20100101)),
          as.Date(ymd(20160101)))

movies <- dfgross %>% 
  distinct(movieserie, serienumber) %>% 
  count(movieserie) %>% 
  arrange(desc(n)) %>% 
  filter(n >= 4) %>% 
  .$movieserie






ggplot(dfgross %>% filter(str_detect(box_id, "harrypotter")),
       aes(date2, gross_to_date)) + 
  geom_line(aes(color = box_id)) +
  geom_dl(aes(label = box_id), method = "last.points") 


ggplot(dfgross %>% filter(str_detect(box_id, "harrypotter")),
       aes(day_number, gross_to_date)) + 
  geom_line(aes(color = box_id)) +
  geom_dl(aes(label = box_id), method = "last.points") + 
  theme_minimal() + 
  theme(legend.position = "none")


