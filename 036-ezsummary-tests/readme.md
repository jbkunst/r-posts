# 
Joshua Kunst  



```r
library("dplyr")
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library("ezsummary")

data(diamonds, package = "ggplot2")
tbl <- diamonds

select_categorical <- function(tbl, nuniques = 10){
  
  selections <- purrr::map_lgl(tbl, function(x) {
    is.character(x) ||
      is.factor(x) ||
      is.logical(x) ||
      (length(unique(x)) <= nuniques) # this is when you have numeric variables with few uniques (dummies)
  })
  tbl[, selections]
  
}

select_quantitative <- function(tbl){
  
  selections <- purrr::map_lgl(tbl, function(x) is.numeric(x))
  tbl[, selections]
  
}

diamonds %>% 
  select_categorical() 
```

```
## Source: local data frame [53,940 x 3]
## 
##          cut  color clarity
##       (fctr) (fctr)  (fctr)
## 1      Ideal      E     SI2
## 2    Premium      E     SI1
## 3       Good      E     VS1
## 4    Premium      I     VS2
## 5       Good      J     SI2
## 6  Very Good      J    VVS2
## 7  Very Good      I    VVS1
## 8  Very Good      H     SI1
## 9       Fair      E     VS2
## 10 Very Good      H     VS1
## ..       ...    ...     ...
```

```r
diamonds %>% 
  select_quantitative()
```

```
## Source: local data frame [53,940 x 7]
## 
##    carat depth table price     x     y     z
##    (dbl) (dbl) (dbl) (int) (dbl) (dbl) (dbl)
## 1   0.23  61.5    55   326  3.95  3.98  2.43
## 2   0.21  59.8    61   326  3.89  3.84  2.31
## 3   0.23  56.9    65   327  4.05  4.07  2.31
## 4   0.29  62.4    58   334  4.20  4.23  2.63
## 5   0.31  63.3    58   335  4.34  4.35  2.75
## 6   0.24  62.8    57   336  3.94  3.96  2.48
## 7   0.24  62.3    57   336  3.95  3.98  2.47
## 8   0.26  61.9    55   337  4.07  4.11  2.53
## 9   0.22  65.1    61   337  3.87  3.78  2.49
## 10  0.23  59.4    61   338  4.00  4.05  2.39
## ..   ...   ...   ...   ...   ...   ...   ...
```

```r
#### ####

# tbl <- diamonds %>% select_categorical() %>%  group_by(cut)
# tbl <- diamonds %>% select_categorical() %>%  group_by(cut, color)

ezsummary_categorical2 <- function(tbl){
  
  grp_cols <- names(attr(tbl, "labels"))
  
  tbl %>%
    purrr::map_if(is.factor, as.character) %>% # avoid warning
    as_data_frame() %>% # this ungroup the tbl
    group_by_(.dots = lapply(grp_cols, as.symbol)) %>%  # http://stackoverflow.com/questions/21208801/
    do({ezsum = 
      tidyr::gather(., key, value) %>% # you can use tidyr::gather(., variable, category)
      ungroup() %>%
      count(key, value) %>% 
      mutate(p = n/sum(n))
    }) %>% 
    # ungroup() %>%
    filter(!key %in% grp_cols) # not sure whiy appear as key a group col
 
}

diamonds %>%
  select_categorical() %>% 
  ezsummary_categorical() 
```

```
## Source: local data frame [20 x 3]
## 
##         variable count     p
##            (chr) (int) (dbl)
## 1       cut_Fair  1610 0.030
## 2       cut_Good  4906 0.091
## 3  cut_Very Good 12082 0.224
## 4    cut_Premium 13791 0.256
## 5      cut_Ideal 21551 0.400
## 6        color_D  6775 0.126
## 7        color_E  9797 0.182
## 8        color_F  9542 0.177
## 9        color_G 11292 0.209
## 10       color_H  8304 0.154
## 11       color_I  5422 0.101
## 12       color_J  2808 0.052
## 13    clarity_I1   741 0.014
## 14   clarity_SI2  9194 0.170
## 15   clarity_SI1 13065 0.242
## 16   clarity_VS2 12258 0.227
## 17   clarity_VS1  8171 0.151
## 18  clarity_VVS2  5066 0.094
## 19  clarity_VVS1  3655 0.068
## 20    clarity_IF  1790 0.033
```

```r
diamonds %>%
  select_categorical() %>% 
  ezsummary_categorical2() 
```

```
## Source: local data frame [20 x 4]
## Groups: key [3]
## 
##        key     value     n          p
##      (chr)     (chr) (int)      (dbl)
## 1  clarity        I1   741 0.01373749
## 2  clarity        IF  1790 0.03318502
## 3  clarity       SI1 13065 0.24221357
## 4  clarity       SI2  9194 0.17044865
## 5  clarity       VS1  8171 0.15148313
## 6  clarity       VS2 12258 0.22725250
## 7  clarity      VVS1  3655 0.06776047
## 8  clarity      VVS2  5066 0.09391917
## 9    color         D  6775 0.12560252
## 10   color         E  9797 0.18162773
## 11   color         F  9542 0.17690026
## 12   color         G 11292 0.20934372
## 13   color         H  8304 0.15394883
## 14   color         I  5422 0.10051910
## 15   color         J  2808 0.05205784
## 16     cut      Fair  1610 0.02984798
## 17     cut      Good  4906 0.09095291
## 18     cut     Ideal 21551 0.39953652
## 19     cut   Premium 13791 0.25567297
## 20     cut Very Good 12082 0.22398962
```

```r
library(rbenchmark)

tblcat <- diamonds %>% select_categorical()
tblcat <- diamonds %>% select_categorical() %>%  group_by(cut, color)

benchmark(
  ezsummary_categorical(tblcat),
  ezsummary_categorical2(tblcat),
  replications = 100
)
```

```
##                             test replications elapsed relative user.self
## 1  ezsummary_categorical(tblcat)          100    1.29    1.000      1.30
## 2 ezsummary_categorical2(tblcat)          100   13.01   10.085     12.95
##   sys.self user.child sys.child
## 1     0.00         NA        NA
## 2     0.01         NA        NA
```

```r
# Mmm not so fast

t1 <- diamonds %>%
  select_categorical() %>% 
  ezsummary_categorical2() 

t1
```

```
## Source: local data frame [20 x 4]
## Groups: key [3]
## 
##        key     value     n          p
##      (chr)     (chr) (int)      (dbl)
## 1  clarity        I1   741 0.01373749
## 2  clarity        IF  1790 0.03318502
## 3  clarity       SI1 13065 0.24221357
## 4  clarity       SI2  9194 0.17044865
## 5  clarity       VS1  8171 0.15148313
## 6  clarity       VS2 12258 0.22725250
## 7  clarity      VVS1  3655 0.06776047
## 8  clarity      VVS2  5066 0.09391917
## 9    color         D  6775 0.12560252
## 10   color         E  9797 0.18162773
## 11   color         F  9542 0.17690026
## 12   color         G 11292 0.20934372
## 13   color         H  8304 0.15394883
## 14   color         I  5422 0.10051910
## 15   color         J  2808 0.05205784
## 16     cut      Fair  1610 0.02984798
## 17     cut      Good  4906 0.09095291
## 18     cut     Ideal 21551 0.39953652
## 19     cut   Premium 13791 0.25567297
## 20     cut Very Good 12082 0.22398962
```

```r
# check how much groups are 
sum(t1$p) == nrow(distinct(t1, key))
```

```
## [1] TRUE
```

```r
t2 <- diamonds %>%
  select_categorical() %>% 
  group_by(cut, color) %>% 
  ezsummary_categorical2()

t2
```

```
## Source: local data frame [276 x 6]
## Groups: cut, color [35]
## 
##      cut color     key value     n          p
##    (chr) (chr)   (chr) (chr) (int)      (dbl)
## 1   Fair     D clarity    I1     4 0.02453988
## 2   Fair     D clarity    IF     3 0.01840491
## 3   Fair     D clarity   SI1    58 0.35582822
## 4   Fair     D clarity   SI2    56 0.34355828
## 5   Fair     D clarity   VS1     5 0.03067485
## 6   Fair     D clarity   VS2    25 0.15337423
## 7   Fair     D clarity  VVS1     3 0.01840491
## 8   Fair     D clarity  VVS2     9 0.05521472
## 9   Fair     E clarity    I1     9 0.04017857
## 10  Fair     E clarity   SI1    65 0.29017857
## ..   ...   ...     ...   ...   ...        ...
```

```r
# check how much groups are 
sum(t2$p) == nrow(distinct(t2, cut, color, key))
```

```
## [1] TRUE
```

```r
mtcars %>% 
  select_categorical(nuniques = 2) %>% 
  ezsummary_categorical2()
```

```
## Source: local data frame [4 x 4]
## Groups: key [2]
## 
##     key value     n       p
##   (chr) (dbl) (int)   (dbl)
## 1    am     0    19 0.59375
## 2    am     1    13 0.40625
## 3    vs     0    18 0.56250
## 4    vs     1    14 0.43750
```


---
title: "readme.R"
author: "jkunst"
date: "Wed Feb 17 15:29:39 2016"
---
