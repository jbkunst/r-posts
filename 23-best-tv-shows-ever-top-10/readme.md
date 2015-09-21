# A brief look to Hollywood's 100 Favorite TV Shows
Joshua Kunst  


```r
# http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm
```


http://www.hollywoodreporter.com/



```r
url <- "http://www.hollywoodreporter.com/lists/best-tv-shows-ever-top-819499/item/desperate-housewives-hollywoods-100-favorite-820451"

items <- html(url) %>% 
  html_nodes(".list--ordered__item")

length(items) == 100 # Yay!
```

```
## [1] TRUE
```

```r
data <- ldply(items, function(item){
  # item <- sample(items, size = 1)[[1]]
  # item <- items[[45]]
  
  name <- item %>% html_node(".list-item__title") %>% html_text()
  

  info <- item %>% html_node(".list-item__deck") %>% html_text()
  
  years <- str_extract_all(info, "\\d+") %>% unlist() %>% as.numeric()
  
  company <- str_replace(info, "\\(.*\\)", "") %>% str_trim()
  
  imdbid <- search_by_title(name, type = "series") %>% filter(grepl(years[1], Year)) %>% .$imdbID %>% .[1]
  
  dsummary <- data_frame(name, from = years[1], to = years[2], company) 
  
  if(!is.null(imdbid)) {
    dsummary <- cbind(dsummary, find_by_id(imdbid)) %>% 
      mutate(main_genre = str_split(Genre, "\\,") %>% unlist() %>% .[1])
  }
    
  dsummary
  
}, .progress = "win")
```

```
## Movie not found!
## Movie not found!
## Movie not found!
## Movie not found!
## Movie not found!
## Movie not found!
## Movie not found!
```

```r
names(data) <- tolower(names(data))

data <- tbl_df(data) %>% 
  mutate(place = rev(seq(100)),
         to = ifelse(is.na(to), 2005, to)) %>% 
  arrange(place) 

data %>%
  select(place, name, company, genre) %>%
  head()
```



 place  name              company   genre                     
------  ----------------  --------  --------------------------
     1  Friends           NBC       Comedy, Romance           
     2  Breaking Bad      AMC       Crime, Drama, Thriller    
     3  The X-Files       Fox       Drama, Mystery, Sci-Fi    
     4  Game of Thrones   HBO       Adventure, Drama, Fantasy 
     5  Seinfeld          NBC       Comedy                    
     6  The Sopranos      HBO       Crime, Drama              

```r
data %>% count(main_genre) %>% arrange(desc(n))
```



main_genre     n
-----------  ---
Comedy        50
Drama         14
Crime          9
Action         8
NA             7
Adventure      5
Animation      5
Fantasy        1
N/A            1

ggplot version:



```r
# ggplot(data) +
#   geom_segment(aes(x = to, xend  = from, y = place, yend = place, group = place, color=name),
#                size = 2, alpha = 0.75) +
#   theme_minimal() +
#   theme(legend.position = "none")


# hc version
# 
# library("taucharts")
# library("tidyr")
# 
# data2 <- data %>%
#   select(name, from, to) %>%
#   gather(key, year, -name) %>% 
#   left_join(data %>% select(name, place), by = "name") %>% 
#   mutate(year2 = lubridate::ymd(paste0(year, "0101")),
#          year3 = as.character(year))
# 
# head(data2)
# 
# tauchart(data2) %>% 
#   tau_line("year3", "place", "name") %>% 
#   tau_tooltip()
# 
# 
# 
# # tau
# 
# # hc version
# 
# hc <- rCharts::Highcharts$new()
# hc$legend(enabled = F)
# hc
# 
# for(i in seq(nrow(data))){
#   d <- data[i,]
#   hc$series(data = list(c(d$from, d$place), c(d$to, d$place)), lineWidth = 7, name = d$name)
# }
# 
# #+ results = 'asis'
# hc$show('inline', include_assets = TRUE, standalone = TRUE)
```


---
title: "readme.R"
author: "Joshua K"
date: "Sat Sep 19 03:51:39 2015"
---
