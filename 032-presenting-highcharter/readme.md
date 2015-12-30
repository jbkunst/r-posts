# Presenting Highcharter
Joshua Kunst  



[Highcharts](http://highcharts.com) was the first javascript library what I used in a long time
ago. Highchartshave a mature API to plot a lot of types of charts. Obviously there are some R 
packages to plot data using this library:

- [Ramnath Vaidyanathan](https://github.com/ramnathv)'s [rCharts](https://github.com/ramnathv/rCharts).
What a library. This was the beginning to the R & JS romance. The rCharts approach to plot data
is object oriented; here we used a lot of `chart$Key(arguments, ...)`.
- [highchartR](https://github.com/jcizel/highchartR) package from [jcizel](https://github.com/jcizel).
This package we use the `highcharts` function and give some parameters, like the variable's names get our
chart.

With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?**. 
The main reasons were:

- Write/code highcharts plots using the piping style and get similar results like 
[dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
[taucharts](http://rpubs.com/hrbrmstr/taucharts),[leaflet](https://rstudio.github.io/leaflet/)
packages.
- Get a way to get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts)
including *themes* and *options* too.
- Generate shortcuts for some R objects. For example time series.
- Put all my love for highcharts in somewhere.

The result? I don't know yet. The users will be judges. I'm just here to show you what can you 
do with this package. So here we go with the demos!

### The Demo ####


```r
library("highcharter")
library("magrittr")
library("dplyr")
```

```
## 
## Attaching package: 'dplyr'
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
knit_print.htmlwidget <- function(x, ..., options = NULL){
  
  
  t <- '<iframe src="http://jkunst.com/htmlwidgets/rchess1.html" height=400 style="border:none; background:transparent; overflow:hidden; width:100%;"></iframe>'
  
  knitr::asis_output(t)
  
}



data("citytemp")

citytemp
```

```
## Source: local data frame [12 x 5]
## 
##    month tokyo new_york berlin london
##    (chr) (dbl)    (dbl)  (dbl)  (dbl)
## 1    Jan   7.0     -0.2   -0.9    3.9
## 2    Feb   6.9      0.8    0.6    4.2
## 3    Mar   9.5      5.7    3.5    5.7
## 4    Apr  14.5     11.3    8.4    8.5
## 5    May  18.2     17.0   13.5   11.9
## 6    Jun  21.5     22.0   17.0   15.2
## 7    Jul  25.2     24.8   18.6   17.0
## 8    Aug  26.5     24.1   17.9   16.6
## 9    Sep  23.3     20.1   14.3   14.2
## 10   Oct  18.3     14.1    9.0   10.3
## 11   Nov  13.9      8.6    3.9    6.6
## 12   Dec   9.6      2.5    1.0    4.8
```

```r
hc <- highchart() %>% 
  hc_add_serie(name = "tokyo", data = citytemp$tokyo)

hc
```

<iframe src="http://jkunst.com/htmlwidgets/rchess1.html" height=400 style="border:none; background:transparent; overflow:hidden; width:100%;"></iframe>

Very simple chart. Here comes the powerful highchart API.


```r
hc <- hc %>% 
  hc_title(text = "Temperatures for some cities") %>% 
  hc_xAxis(categories = citytemp$month) %>% 
  hc_add_serie(name = "London", data = citytemp$london,
               dataLabels = list(enabled = TRUE)) %>% 
  hc_yAxis(title = list(text = "Temperature"),
           labels = list(format = "{value}° C")) 
  
hc
```

<iframe src="http://jkunst.com/htmlwidgets/rchess1.html" height=400 style="border:none; background:transparent; overflow:hidden; width:100%;"></iframe>

And finally we can add a theme.


```r
hc <- hc %>% 
  hc_add_serie(name = "New York", data = citytemp$new_york, type = "spline") %>% 
  hc_add_theme(hc_theme_sandsignika())
  
hc
```

<iframe src="http://jkunst.com/htmlwidgets/rchess1.html" height=400 style="border:none; background:transparent; overflow:hidden; width:100%;"></iframe>

### Some shortcuts ####
For ts objects


```r
highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") %>% 
  hc_add_theme(hc_theme_darkunica())
```

<iframe src="http://jkunst.com/htmlwidgets/rchess1.html" height=400 style="border:none; background:transparent; overflow:hidden; width:100%;"></iframe>

### With Great Power Comes Great Responsibility ####
![Save pie!](http://cdn.meme.am/instances2/500x/3594501.jpg)

You can use this pacakge for evil purposes so be careful


```r
iriscount <- count(iris, Species)
iriscount
```

```
## Source: local data frame [3 x 2]
## 
##      Species     n
##       (fctr) (int)
## 1     setosa    50
## 2 versicolor    50
## 3  virginica    50
```

```r
highchart() %>% 
  hc_title(text = "Ñom a delicious pie!") %>% 
  hc_chart(type = "pie", options3d = list(enabled = TRUE, alpha = 70, beta = 0)) %>% 
  hc_plotOptions(pie = list(depth = 70)) %>% 
  hc_add_serie_labels_values(iriscount$Species, iriscount$n) %>% 
  hc_add_theme(hc_theme(
    chart = list(
      backgroundColor = NULL,
      divBackgroundImage = "https://media.giphy.com/media/Yy26NRbpB9lDi/giphy.gif"
    )
  ))
```

<iframe src="http://jkunst.com/htmlwidgets/rchess1.html" height=400 style="border:none; background:transparent; overflow:hidden; width:100%;"></iframe>



---
title: "readme.R"
author: "jkunst"
date: "Wed Dec 30 17:28:30 2015"
---
