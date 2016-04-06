# 
Joshua Kunst  




## Data



```r
URL <- "http://graphics8.nytimes.com/newsgraphics/2016/01/15/drug-deaths/c23ba79c9c9599a103a8d60e2329be1a9b7d6994/data.json"

color_stops <- function(n = 10, option = "D") {
  
  data.frame(q = seq(0, n)/n,
             c = substring(viridis(n + 1, option = "D"), 0, 7)) %>% 
    list.parse2()
}
  

data("uscountygeojson")
data("unemployment")

data <-  fromJSON(URL) %>% 
  tbl_df() %>% 
  gather(year, value, -fips) %>% 
  mutate(year = sub("^y", "", year))

count(data, year)
```

```
## Source: local data frame [13 x 2]
## 
##     year     n
##    (chr) (int)
## 1   2002  3141
## 2   2003  3141
## 3   2004  3141
## 4   2005  3141
## 5   2006  3141
## 6   2007  3141
## 7   2008  3141
## 8   2009  3141
## 9   2010  3141
## 10  2011  3141
## 11  2012  3141
## 12  2013  3141
## 13  2014  3141
```

```r
# 
# highchart() %>% 
#   hc_add_series_map(map = uscountygeojson,
#                     df = data %>% filter(year == max(year)) %>% select(fips, value),
#                     value = "value", joinBy = c("fips"),
#                     borderWidth = 0.1) %>% 
#   hc_colorAxis(stops = color_stops()) 


ds <- data %>% 
  group_by(fips) %>% 
  do(item = list(
    fips = first(.$fips),
    sequence = .$value,
    value = first(.$value))) %>% 
  .$item


hc <- highchart(type = "map") %>% 
  hc_add_series(data = ds,
                name = "drug deaths per 100,000",
                mapData = uscountygeojson,
                joinBy = "fips",
                borderWidth = 0.01) %>% 
  hc_colorAxis(stops = color_stops()) %>% 
  hc_motion(
    enabled = TRUE,
    axisLabel = "year",
    labels = sort(unique(data$year)),
    series = 0,
    updateIterval = 50,
    magnet = list(
     round = "floor",
     step = 0.1
    )
  )

hc
```

<!--html_preserve--><div id="htmlwidget-1337" style="width:100%;height:500px;" class="highchart html-widget"></div>


---
title: "readme.R"
author: "jkunst"
date: "Wed Apr 06 16:52:53 2016"
---