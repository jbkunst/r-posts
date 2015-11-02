# Download FA list
Joshua Kunst  
http://fortawesome.github.io/Font-Awesome/cheatsheet/


```r
library("rvest")
```

```
## Loading required package: xml2
```

```r
library("plyr")
library("dplyr")
```

```
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:plyr':
## 
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library("stringr")

rm(list = ls())

icons <- read_html("http://fortawesome.github.io/Font-Awesome/cheatsheet/") %>% 
  html_nodes("div.col-md-4.col-sm-6.col-lg-3")

dficons <- ldply(icons, function(divico){ # divico <- sample(icons, size = 1)[[1]]
    txt <- html_text(divico)
    data_frame(name = str_extract(txt, "fa-.*"),
               unicode = str_extract(txt, "\\[.*\\]") %>% str_replace_all("\\[|\\]", ""))
  }) 

dficons <- tbl_df(dficons)

dficons
```

```
## Source: local data frame [674 x 2]
## 
##                name  unicode
##               (chr)    (chr)
## 1          fa-500px &#xf26e;
## 2         fa-adjust &#xf042;
## 3            fa-adn &#xf170;
## 4   fa-align-center &#xf037;
## 5  fa-align-justify &#xf039;
## 6     fa-align-left &#xf036;
## 7    fa-align-right &#xf038;
## 8         fa-amazon &#xf270;
## 9      fa-ambulance &#xf0f9;
## 10        fa-anchor &#xf13d;
## ..              ...      ...
```


---
title: "readme.R"
author: "jkunst"
date: "Mon Nov 02 11:47:31 2015"
---
