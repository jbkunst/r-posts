# 
Joshua Kunst  






```r
library(weatherData)
library(highcharter)
library(dplyr)
library(lubridate)


data <- getDetailedWeather("KSFO", Sys.Date() - 1)

names(data) <- tolower(names(data))

data <- tbl_df(data)

data$time <- Sys.Date() - 1 + hms(sprintf("%s:00:00", 0:24))

highchart() %>% 
  hc_chart(type = "spline") %>% 
  hc_add_series_times_values(data$time, data$temperaturec) %>% 
  hc_yAxis(min = 0) %>% 
  hc_xAxis(labels = list(format = "{value:%H:%M}"),
           showFirstLabel = FALSE, showLastLabel = FALSE)
```

<!--html_preserve--><div id="htmlwidget-44" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-44">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":null},"min":0},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"chart":{"type":"spline"},"xAxis":{"type":"datetime","labels":{"format":"{value:%H:%M}"},"showFirstLabel":false,"showLastLabel":false},"series":[{"marker":{"enabled":false},"data":[[1471219200000,12.8],[1471222800000,12.8],[1471226400000,13.3],[1471230000000,13.3],[1471233600000,13.3],[1471237200000,12.8],[1471240800000,13.3],[1471244400000,13.3],[1471248000000,14.4],[1471251600000,14.4],[1471255200000,16.1],[1471258800000,17.8],[1471262400000,18.3],[1471266000000,19.4],[1471269600000,20.6],[1471273200000,20],[1471276800000,19.4],[1471280400000,18.9],[1471284000000,18.3],[1471287600000,16.1],[1471291200000,15],[1471294800000,14.4],[1471298400000,13.9],[1471302000000,13.9],[1471305600000,13.9]]}]},"theme":{"chart":{"backgroundColor":"transparent"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":[],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


---
title: "readme.R"
author: "jkunst"
date: "Tue Aug 16 17:24:30 2016"
---
