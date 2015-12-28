# Presenting Highcharter
Joshua Kunst  



```r
rm(list = ls())
library("highcharter")
library("magrittr")
library("dplyr")


#
mtcyl <- count(mtcars, cyl)

highchart() %>% 
  hc_title(text = "Motor Trend Car Road Tests") %>%
  hc_subtitle(text = "1974 Motor Trend US magazie", useHTML = TRUE) %>% 
  hc_xAxis(title = list(text = "Weight")) %>% 
  hc_yAxis(title = list(text = "Miles/gallon")) %>%
  hc_add_serie_scatter(mtcars$wt, mtcars$mpg, mtcars$cyl) %>% 
  hc_add_serie_labels_values(mtcyl$cyl, mtcyl$n, type = "pie", name = "Total",
                             colorByPoint = TRUE, center = c('80%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_add_theme(hc_theme_sandsignika())
```

<!--html_preserve--><div id="htmlwidget-9235" style="width:672px;height:480px;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-9235">{"x":{"hc_opts":{"title":{"text":"Motor Trend Car Road Tests"},"credits":{"enabled":false},"subtitle":{"text":"1974 Motor Trend US magazie","useHTML":true},"xAxis":{"title":{"text":"Weight"}},"yAxis":{"title":{"text":"Miles/gallon"}},"series":[{"type":"scatter","data":[[2.32,22.8],[3.19,24.4],[3.15,22.8],[2.2,32.4],[1.615,30.4],[1.835,33.9],[2.465,21.5],[1.935,27.3],[2.14,26],[1.513,30.4],[2.78,21.4]],"name":"4"},{"type":"scatter","data":[[2.62,21],[2.875,21],[3.215,21.4],[3.46,18.1],[3.44,19.2],[3.44,17.8],[2.77,19.7]],"name":"6"},{"type":"scatter","data":[[3.44,18.7],[3.57,14.3],[4.07,16.4],[3.73,17.3],[3.78,15.2],[5.25,10.4],[5.424,10.4],[5.345,14.7],[3.52,15.5],[3.435,15.2],[3.84,13.3],[3.845,19.2],[3.17,15.8],[3.57,15]],"name":"8"},{"data":[{"name":4,"y":11},{"name":6,"y":7},{"name":8,"y":14}],"type":"pie","name":"Total","colorByPoint":true,"center":["80%","10%"],"size":100,"dataLabels":{"enabled":false}}]},"theme":{"colors":["#f45b5b","#8085e9","#8d4654","#7798BF","#aaeeee","#ff0066","#eeaaee","#55BF3B","#DF5353","#7798BF","#aaeeee"],"chart":{"backgroundColor":null,"divBackgroundImage":"http://www.highcharts.com/samples/graphics/sand.png","style":{"fontFamily":"Signika, serif"}},"title":{"style":{"color":"black","fontSize":"16px","fontWeight":"bold"}},"subtitle":{"style":{"color":"black"}},"tooltip":{"borderWidth":0},"legend":{"itemStyle":{"fontWeight":"bold","fontSize":"13px"}},"xAxis":{"labels":{"style":{"color":"#6e6e70"}}},"yAxis":{"labels":{"style":{"color":"#6e6e70"}}},"plotOptions":{"series":{"shadow":true},"candlestick":{"lineColor":"#404048"},"map":{"shadow":false}},"navigator":{"xAxis":{"gridLineColor":"#D0D0D8"}},"rangeSelector":{"buttonTheme":{"fill":"white","stroke":"#C0C0C8","stroke-width":1,"states":{"select":{"fill":"#D0D0D8"}}}},"scrollbar":{"trackBorderColor":"#C0C0C8"},"background2":"#E0E0E8"},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":"Signika"},"evals":[]}</script><!--/html_preserve-->

```r
data("favorite_bars")
data("favorite_pies")

highchart() %>% 
  hc_title(text = "This is a bar graph describing my favorite pies
           including a pie chart describing my favorite bars") %>%
  hc_subtitle(text = "In percentage of tastiness and awesomeness") %>% 
  hc_add_serie_labels_values(favorite_pies$pie, favorite_pies$percent,
                             colorByPoint = TRUE, type = "column") %>% 
  hc_add_serie_labels_values(favorite_bars$bar, favorite_bars$percent, type = "pie", 
                             colorByPoint = TRUE, center = c('35%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_yAxis(title = list(text = "percentage of tastiness"),
           labels = list(format = "{value}%"), max = 100) %>% 
  hc_xAxis(categories = favorite_pies$pie) %>% 
  hc_legend(enabled = FALSE)
```

<!--html_preserve--><div id="htmlwidget-1418" style="width:672px;height:480px;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-1418">{"x":{"hc_opts":{"title":{"text":"This is a bar graph describing my favorite pies\n           including a pie chart describing my favorite bars"},"credits":{"enabled":false},"subtitle":{"text":"In percentage of tastiness and awesomeness"},"series":[{"data":[{"name":"Strawberry Rhubarb","y":85},{"name":"Pumpkin","y":64},{"name":"Lemon Meringue","y":75},{"name":"Blueberry","y":100},{"name":"Key Lime","y":57}],"colorByPoint":true,"type":"column"},{"data":[{"name":"Mclaren's","y":30},{"name":"McGee's","y":28},{"name":"P & G","y":27},{"name":"White Horse Tavern","y":12},{"name":"King Cole Bar","y":3}],"type":"pie","colorByPoint":true,"center":["35%","10%"],"size":100,"dataLabels":{"enabled":false}}],"yAxis":{"title":{"text":"percentage of tastiness"},"labels":{"format":"{value}%"},"max":100},"xAxis":{"categories":["Strawberry Rhubarb","Pumpkin","Lemon Meringue","Blueberry","Key Lime"]},"legend":{"enabled":false}},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->


---
title: "readme.R"
author: "jkunst"
date: "Mon Dec 28 15:44:20 2015"
---
