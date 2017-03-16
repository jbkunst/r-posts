# 
Joshua Kunst  



```r
# packages ----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(jbkmisc)
theme_set(theme_jbk())

# data --------------------------------------------------------------------
# dprod <- read_csv("http://atlas.media.mit.edu/en/rankings/hs92/?download=true")
# names(dprod) <- tolower(names(dprod))
# dprod

data <- read_csv("http://atlas.media.mit.edu/en/rankings/country/?download=true")
names(data) <- tolower(names(data))
data
```

```
## # A tibble: 5,881 × 5
##     year  rank    id        country     eci
##    <int> <int> <chr>          <chr>   <dbl>
## 1   1964     1   che    Switzerland 2.30660
## 2   1964     2   swe         Sweden 2.25070
## 3   1964     3   aut        Austria 2.20926
## 4   1964     4   gbr United Kingdom 2.16646
## 5   1964     5   jpn          Japan 2.11512
## 6   1964     6   fra         France 2.01915
## 7   1964     7   usa  United States 2.01312
## 8   1964     8   ita          Italy 1.94026
## 9   1964     9   bel        Belgium 1.88107
## 10  1964    10   nor         Norway 1.73035
## # ... with 5,871 more rows
```

```r
# explore -----------------------------------------------------------------
data %>% 
  count(year) %>% 
  ggplot() +
  geom_line(aes(year, n)) # + scale_y_continuous(limits = c(0, NA))
```

![](readme_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

```r
countries_to_study <- data %>% 
  group_by(country) %>% 
  summarise(year_min = min(year))
```


---
title: "readme.R"
author: "joshua.kunst"
date: "Thu Mar 16 18:02:06 2017"
---
