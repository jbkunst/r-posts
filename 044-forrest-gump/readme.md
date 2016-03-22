# Watching Forrest Gump through the Data
Joshua Kunst  




> I'm not a man but I (*think to*) know what data is




```r
urltl <- "http://www.timetoast.com/timelines/forrest-gump-timeline-of-events-and-major-figures"

df <- read_html(urltl) %>% 
  html_nodes("table tr") %>% 
  .[-c(1, length(.)-1, length(.))] %>% 
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
```

```
## Source: local data frame [19 x 4]
## 
##                                id
##                             (chr)
## 1                   forrest gump3
## 2                          elvis1
## 3                      bearbryant
## 4                        wallace1
## 5                        timeline
## 6                        kennedy1
## 7                     gumpvietnam
## 8       jennyforrestgumpistapeace
## 9                        kennedy2
## 10                           moh2
## 11 war protest washington 267x400
## 12                    moonlanding
## 13                      gumpchina
## 14                     gumplennon
## 15                  gumpwatergate
## 16                         carmen
## 17             apple forrest gump
## 18   reagan assassination attempt
## 19                      jennyaids
## Variables not shown: name (chr), time (chr), imgurl (chr)
```


---
title: "readme.R"
author: "jkunst"
date: "Tue Mar 22 18:34:58 2016"
---
