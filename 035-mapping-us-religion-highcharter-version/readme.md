# 
Joshua Kunst  



Source: http://www.arilamstein.com/blog/2016/01/25/mapping-us-religion-adherence-county-r/

This is a try to implement the choropleth using [highcarter](http://jkunst.com/highcharter),
Download the data:



```r
library(haven)
library(dplyr)
library(stringr)

url <- "http://www.thearda.com/download/download.aspx?file=U.S.%20Religion%20Census%20Religious%20Congregations%20and%20Membership%20Study,%202010%20(County%20File).SAV"

data <- read_sav(url)

data[, tail(seq(ncol(data)), -560)]
```

```
## Source: local data frame [3,149 x 8]
## 
##    ZORORATE  FIPS STCODE STABBR  STNAME CNTYCODE        CNTYNAME POP2010
##       (dbl) (dbl)  (dbl)  (chr)   (chr)    (dbl)           (chr)   (dbl)
## 1      0.05  1001      1     AL Alabama        1  Autauga County   54571
## 2        NA  1003      1     AL Alabama        3  Baldwin County  182265
## 3        NA  1005      1     AL Alabama        5  Barbour County   27457
## 4        NA  1007      1     AL Alabama        7     Bibb County   22915
## 5        NA  1009      1     AL Alabama        9   Blount County   57322
## 6        NA  1011      1     AL Alabama       11  Bullock County   10914
## 7        NA  1013      1     AL Alabama       13   Butler County   20947
## 8        NA  1015      1     AL Alabama       15  Calhoun County  118572
## 9        NA  1017      1     AL Alabama       17 Chambers County   34215
## 10       NA  1019      1     AL Alabama       19 Cherokee County   25989
## ..      ...   ...    ...    ...     ...      ...             ...     ...
```

```r
data <- data %>% 
  mutate(CODE = paste("us",
                      tolower(STABBR),
                      str_pad(CNTYCODE, width = 3, pad = "0"),
                      sep = "-"))

data[, tail(seq(ncol(data)), -560)]
```

```
## Source: local data frame [3,149 x 9]
## 
##    ZORORATE  FIPS STCODE STABBR  STNAME CNTYCODE        CNTYNAME POP2010
##       (dbl) (dbl)  (dbl)  (chr)   (chr)    (dbl)           (chr)   (dbl)
## 1      0.05  1001      1     AL Alabama        1  Autauga County   54571
## 2        NA  1003      1     AL Alabama        3  Baldwin County  182265
## 3        NA  1005      1     AL Alabama        5  Barbour County   27457
## 4        NA  1007      1     AL Alabama        7     Bibb County   22915
## 5        NA  1009      1     AL Alabama        9   Blount County   57322
## 6        NA  1011      1     AL Alabama       11  Bullock County   10914
## 7        NA  1013      1     AL Alabama       13   Butler County   20947
## 8        NA  1015      1     AL Alabama       15  Calhoun County  118572
## 9        NA  1017      1     AL Alabama       17 Chambers County   34215
## 10       NA  1019      1     AL Alabama       19 Cherokee County   25989
## ..      ...   ...    ...    ...     ...      ...             ...     ...
## Variables not shown: CODE (chr)
```

```r
library(highcharter)
data("uscountygeojson")
```

Adding viridis palette:



```r
require("viridisLite")
n <- 32
dstops <- data.frame(q = 0:n/n, c = substring(viridis(n + 1), 0, 7))
dstops <- list.parse2(dstops)


highchart() %>% 
  hc_title(text = "Total Religious Adherents by County") %>% 
  hc_add_series_map(map = uscountygeojson, df = data,
                    value = "TOTRATE", joinBy = c("code", "CODE"),
                    name = "Adherents", borderWidth = 0.5) %>% 
  hc_colorAxis(stops = dstops, min = 0, max = 1000) %>% 
  hc_legend(layout = "vertical", reversed = TRUE,
            floating = TRUE, align = "right") %>% 
  hc_mapNavigation(enabled = TRUE, align = "right") %>% 
  hc_tooltip(valueDecimals = 0)
```

<!--html_preserve--><div id="htmlwidget-7936" style="width:100%;height:500px;" class="highchart"></div>


---
title: "readme.R"
author: "Joshua K"
date: "Mon Jan 25 23:09:37 2016"
---