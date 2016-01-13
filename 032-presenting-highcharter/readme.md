# Presenting Highcharter
Joshua Kunst  



After a lot of documentation, `R CMD check`s and a lot of patience from CRAN
people I'm happy to anonounce [highcharter](http://jkunst.com/highcharter) v0.1.0:
A(nother) wrapper for [Highcharts](http://highcharts.com) charting library.

[I like Highcharts(http://jkunst.com/r/ggplot-with-a-highcharts-taste/). It was the 
first charting javascript library what I used in a long time and have
very a mature API to plot a lot of types of charts. Obviously there are some R 
packages to plot data using this library:

- [Ramnath Vaidyanathan](https://github.com/ramnathv)'s [rCharts](https://github.com/ramnathv/rCharts).
What a library. This was the beginning to the R & JS romance. The `rCharts` approach to plot data
is object oriented; here we used a lot of `chart$Key(arguments, ...)`.
- [highchartR](https://github.com/jcizel/highchartR) package from [jcizel](https://github.com/jcizel).
This package we use the `highcharts` function and give some parameters, like the variable's names get our
chart.

With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?**. 
The main reasons were/are:

- Write/code highcharts plots using the piping style and get similar results like 
[dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
[taucharts](http://rpubs.com/hrbrmstr/taucharts), [leaflet](https://rstudio.github.io/leaflet/)
packages.
- Get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts).  
This mean we have here a *raw* wrapper in the sense that you maybe need to make/construct the chart by hand
not so R user friendly but with some shortcuts to plot R objects. So you can plot  
including [*themes*](http://jkunst.com/highcharter/#themes) and *options*.
- Generate shortcuts for some R objects. For example time series.
- Put all my love for highcharts in somewhere.

The result? I don't know yet. The users will be judges. I'm just here to show you what can you 
do with this package. So here we go with the demos!

### The Demo ####

Let's see a simple chart.



```r
library("highcharter")
library("magrittr")
library("dplyr")

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

<!--html_preserve--><div id="htmlwidget-1223" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-1223">{"x":{"hc_opts":{"title":{"text":null},"credits":{"enabled":false},"exporting":{"enabled":false},"series":[{"name":"tokyo","data":[7,6.9,9.5,14.5,18.2,21.5,25.2,26.5,23.3,18.3,13.9,9.6]}]},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

Very simple chart. Here comes the powerful highchart API: Adding more series
data and adding themes.


```r
hc <- hc %>% 
  hc_title(text = "Temperatures for some cities") %>% 
  hc_xAxis(categories = citytemp$month) %>% 
  hc_add_serie(name = "London", data = citytemp$london,
               dataLabels = list(enabled = TRUE)) %>%
  hc_add_serie(name = "New York", data = citytemp$new_york,
               type = "spline") %>% 
  hc_yAxis(title = list(text = "Temperature"),
           labels = list(format = "{value}° C")) %>%
  hc_add_theme(hc_theme_sandsignika())
```

### Some examples ####
For ts objects


```r
highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") 
```

<!--html_preserve--><div id="htmlwidget-9065" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-9065">{"x":{"hc_opts":{"title":{"text":"Monthly Deaths from Lung Diseases in the UK"},"credits":{"enabled":false},"exporting":{"enabled":false},"xAxis":{"type":"datetime"},"series":[{"marker":{"enabled":false},"data":[[126230400000,901],[128908800000,689],[131328000000,827],[134006400000,677],[136598400000,522],[139276800000,406],[141868800000,441],[144547200000,393],[147225600000,387],[149817600000,582],[152496000000,578],[155088000000,666],[157766400000,830],[160444800000,752],[162864000000,785],[165542400000,664],[168134400000,467],[170812800000,438],[173404800000,421],[176083200000,412],[178761600000,343],[181353600000,440],[184032000000,531],[186624000000,771],[189302400000,767],[191980800000,1141],[194486400000,896],[197164800000,532],[199756800000,447],[202435200000,420],[205027200000,376],[207705600000,330],[210384000000,357],[212976000000,445],[215654400000,546],[218246400000,764],[220924800000,862],[223603200000,660],[226022400000,663],[228700800000,643],[231292800000,502],[233971200000,392],[236563200000,411],[239241600000,348],[241920000000,387],[244512000000,385],[247190400000,411],[249782400000,638],[252460800000,796],[255139200000,853],[257558400000,737],[260236800000,546],[262828800000,530],[265507200000,446],[268099200000,431],[270777600000,362],[273456000000,387],[276048000000,430],[278726400000,425],[281318400000,679],[283996800000,821],[286675200000,785],[289094400000,727],[291772800000,612],[294364800000,478],[297043200000,429],[299635200000,405],[302313600000,379],[304992000000,393],[307584000000,411],[310262400000,487],[312854400000,574]],"name":"Female"},{"marker":{"enabled":false},"data":[[126230400000,2134],[128908800000,1863],[131328000000,1877],[134006400000,1877],[136598400000,1492],[139276800000,1249],[141868800000,1280],[144547200000,1131],[147225600000,1209],[149817600000,1492],[152496000000,1621],[155088000000,1846],[157766400000,2103],[160444800000,2137],[162864000000,2153],[165542400000,1833],[168134400000,1403],[170812800000,1288],[173404800000,1186],[176083200000,1133],[178761600000,1053],[181353600000,1347],[184032000000,1545],[186624000000,2066],[189302400000,2020],[191980800000,2750],[194486400000,2283],[197164800000,1479],[199756800000,1189],[202435200000,1160],[205027200000,1113],[207705600000,970],[210384000000,999],[212976000000,1208],[215654400000,1467],[218246400000,2059],[220924800000,2240],[223603200000,1634],[226022400000,1722],[228700800000,1801],[231292800000,1246],[233971200000,1162],[236563200000,1087],[239241600000,1013],[241920000000,959],[244512000000,1179],[247190400000,1229],[249782400000,1655],[252460800000,2019],[255139200000,2284],[257558400000,1942],[260236800000,1423],[262828800000,1340],[265507200000,1187],[268099200000,1098],[270777600000,1004],[273456000000,970],[276048000000,1140],[278726400000,1110],[281318400000,1812],[283996800000,2263],[286675200000,1820],[289094400000,1846],[291772800000,1531],[294364800000,1215],[297043200000,1075],[299635200000,1056],[302313600000,975],[304992000000,940],[307584000000,1081],[310262400000,1294],[312854400000,1341]],"name":"Male"}]},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

A more elaborated xample



```r
hc <- highchart() %>% 
  hc_title(text = "Motor Trend Car Road Tests") %>% 
  hc_subtitle(text = "Source: 1974 Motor Trend US magazine") %>% 
  hc_xAxis(title = list(text = "Weight")) %>% 
  hc_yAxis(title = list(text = "Miles/gallon")) %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_add_serie_scatter(mtcars$wt, mtcars$mpg,
                       mtcars$drat, mtcars$hp,
                       rownames(mtcars),
                       dataLabels = list(
                         enabled = TRUE,
                         format = "{point.label}"
                       )) %>% 
  hc_tooltip(useHTML = TRUE,
             headerFormat = "<table>",
             pointFormat = paste("<tr><th colspan=\"1\"><b>{point.label}</b></th></tr>",
                                 "<tr><th>Weight</th><td>{point.x} lb/1000</td></tr>",
                                 "<tr><th>MPG</th><td>{point.y} mpg</td></tr>",
                                 "<tr><th>Drat</th><td>{point.z} </td></tr>",
                                 "<tr><th>HP</th><td>{point.valuecolor} hp</td></tr>"),
             footerFormat = "</table>")
```

### You can do anything ####
As uncle Bem said some day:

![SavePie](https://raw.githubusercontent.com/jbkunst/r-posts/master/032-presenting-highcharter/save%20pie.jpg)

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
  hc_title(text = "Nom! a delicious 3d pie!") %>% 
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

<!--html_preserve--><div id="htmlwidget-9175" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-9175">{"x":{"hc_opts":{"title":{"text":"Nom! a delicious 3d pie!"},"credits":{"enabled":false},"exporting":{"enabled":false},"chart":{"type":"pie","options3d":{"enabled":true,"alpha":70,"beta":0}},"plotOptions":{"pie":{"depth":70}},"series":[{"data":[{"name":"setosa","y":50},{"name":"versicolor","y":50},{"name":"virginica","y":50}]}]},"theme":{"chart":{"backgroundColor":null,"divBackgroundImage":"https://media.giphy.com/media/Yy26NRbpB9lDi/giphy.gif"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->



---
title: "readme.R"
author: "Joshua K"
date: "Wed Jan 13 07:53:43 2016"
---
