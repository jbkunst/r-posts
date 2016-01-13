# Presenting Highcharter
Joshua Kunst  



After a lot of documentation, a lot of `R CMD check`s and a lot of patience from CRAN
people I'm happy to anonounce [highcharter](http://jkunst.com/highcharter) v0.1.0:
*A(nother) wrapper for [Highcharts](http://highcharts.com) charting library*.

[I like Highcharts](http://jkunst.com/r/ggplot-with-a-highcharts-taste/). It was the 
first charting javascript library what I used in a long time and have
very a mature API to plot a lot of types of charts. Obviously there are some R 
packages to plot data using this library:

- [Ramnath Vaidyanathan](https://github.com/ramnathv)'s [rCharts](https://github.com/ramnathv/rCharts).
What a library. This was the beginning to the R & JS romance. The `rCharts` approach to plot data
is object oriented; here we used a lot of `chart$Key(arguments, ...)`.
- [highchartR](https://github.com/jcizel/highchartR) package from [jcizel](https://github.com/jcizel).
This package we use the `highcharts` function and give some parameters, like the variable's names 
get our chart.

With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?** 
The main reasons were/are:

- Write/code highcharts plots using the piping style and get similar results like 
[dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
[taucharts](http://rpubs.com/hrbrmstr/taucharts), [leaflet](https://rstudio.github.io/leaflet/)
packages.
- Get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts). This mean 
made a not so useR-friendly wrapper in the sense that you maybe need to make/construct 
the chart parmeter by parameter. But don't worry, there are some *shortcuts* functions to
plot some R objects in the fly (see the examples below).
- Include and create [*themes*](http://jkunst.com/highcharter/#themes) :D.
- Put all my love for highcharts in somewhere.

### Some Q&A ####

**When use this package?** I recommend use this when you have fihinsh your analysis and you want
to show your result with some interactivity. So, before use experimental plot to visualize, explore
the data with **ggplot2** then use **highcharter** as one of the various alternatives what we have
in ou*R* community like ggivs, dygraphs, taucharts, metricsgraphics, plotly among others 
(please check hafen's [htmlwidgets gallery](http://hafen.github.io/htmlwidgetsgallery/))

**What are the advantages of using this package?** Basically the advantages are inherited from
hicharts: have a numerous chart tpyes with the **same** format, style, flavour. I think in a
situation when you use a treemap and a scatter chart from differents packages in a shiny app.
The posibility to create or modify themes (I like this a lot!). Have the possibility to
customize in every way your chart: beatiful tooltips, title, 
[add plotlines or plotbands](http://jkunst.com/highcharter/#hc_xaxis-and-hc_yaxis).

**What are the disadvantages of this package and highcharts?** One thing I miss is the facet 
implementation like in taucharts and hrbrmstr's [taucharts](http://rpubs.com/hrbrmstr/taucharts).
This is not really necesary but it's really good when a visualization library has it. Maybe 
other disadvantage of *this* implmentation is the functions use standar evaluation 
`plot(data$x, data$y)` instead something more direct like `plot(data, ~x, ~y)`. That's why
I recommed this package to make the final chart instead use the package to explorer visually
the data.

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

<!--html_preserve--><div id="htmlwidget-6249" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-6249">{"x":{"hc_opts":{"title":{"text":null},"credits":{"enabled":false},"exporting":{"enabled":false},"series":[{"name":"tokyo","data":[7,6.9,9.5,14.5,18.2,21.5,25.2,26.5,23.3,18.3,13.9,9.6]}]},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

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
           labels = list(format = "{value}? C")) %>%
  hc_add_theme(hc_theme_sandsignika())

hc
```

<!--html_preserve--><div id="htmlwidget-1109" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-1109">{"x":{"hc_opts":{"title":{"text":"Temperatures for some cities"},"credits":{"enabled":false},"exporting":{"enabled":false},"series":[{"name":"tokyo","data":[7,6.9,9.5,14.5,18.2,21.5,25.2,26.5,23.3,18.3,13.9,9.6]},{"name":"London","data":[3.9,4.2,5.7,8.5,11.9,15.2,17,16.6,14.2,10.3,6.6,4.8],"dataLabels":{"enabled":true}},{"name":"New York","data":[-0.2,0.8,5.7,11.3,17,22,24.8,24.1,20.1,14.1,8.6,2.5],"type":"spline"}],"xAxis":{"categories":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]},"yAxis":{"title":{"text":"Temperature"},"labels":{"format":"{value}? C"}}},"theme":{"colors":["#f45b5b","#8085e9","#8d4654","#7798BF","#aaeeee","#ff0066","#eeaaee","#55BF3B","#DF5353","#7798BF","#aaeeee"],"chart":{"backgroundColor":null,"divBackgroundImage":"http://www.highcharts.com/samples/graphics/sand.png","style":{"fontFamily":"Signika, serif"}},"title":{"style":{"color":"black","fontSize":"16px","fontWeight":"bold"}},"subtitle":{"style":{"color":"black"}},"tooltip":{"borderWidth":0},"legend":{"itemStyle":{"fontWeight":"bold","fontSize":"13px"}},"xAxis":{"labels":{"style":{"color":"#6e6e70"}}},"yAxis":{"labels":{"style":{"color":"#6e6e70"}}},"plotOptions":{"series":{"shadow":false},"candlestick":{"lineColor":"#404048"},"map":{"shadow":false}},"navigator":{"xAxis":{"gridLineColor":"#D0D0D8"}},"rangeSelector":{"buttonTheme":{"fill":"white","stroke":"#C0C0C8","stroke-width":1,"states":{"select":{"fill":"#D0D0D8"}}}},"scrollbar":{"trackBorderColor":"#C0C0C8"},"background2":"#E0E0E8"},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":"Signika"},"evals":[]}</script><!--/html_preserve-->

### Some examples ####
For ts objects


```r
highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") 
```

<!--html_preserve--><div id="htmlwidget-9515" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-9515">{"x":{"hc_opts":{"title":{"text":"Monthly Deaths from Lung Diseases in the UK"},"credits":{"enabled":false},"exporting":{"enabled":false},"xAxis":{"type":"datetime"},"series":[{"marker":{"enabled":false},"data":[[126230400000,901],[128908800000,689],[131328000000,827],[134006400000,677],[136598400000,522],[139276800000,406],[141868800000,441],[144547200000,393],[147225600000,387],[149817600000,582],[152496000000,578],[155088000000,666],[157766400000,830],[160444800000,752],[162864000000,785],[165542400000,664],[168134400000,467],[170812800000,438],[173404800000,421],[176083200000,412],[178761600000,343],[181353600000,440],[184032000000,531],[186624000000,771],[189302400000,767],[191980800000,1141],[194486400000,896],[197164800000,532],[199756800000,447],[202435200000,420],[205027200000,376],[207705600000,330],[210384000000,357],[212976000000,445],[215654400000,546],[218246400000,764],[220924800000,862],[223603200000,660],[226022400000,663],[228700800000,643],[231292800000,502],[233971200000,392],[236563200000,411],[239241600000,348],[241920000000,387],[244512000000,385],[247190400000,411],[249782400000,638],[252460800000,796],[255139200000,853],[257558400000,737],[260236800000,546],[262828800000,530],[265507200000,446],[268099200000,431],[270777600000,362],[273456000000,387],[276048000000,430],[278726400000,425],[281318400000,679],[283996800000,821],[286675200000,785],[289094400000,727],[291772800000,612],[294364800000,478],[297043200000,429],[299635200000,405],[302313600000,379],[304992000000,393],[307584000000,411],[310262400000,487],[312854400000,574]],"name":"Female"},{"marker":{"enabled":false},"data":[[126230400000,2134],[128908800000,1863],[131328000000,1877],[134006400000,1877],[136598400000,1492],[139276800000,1249],[141868800000,1280],[144547200000,1131],[147225600000,1209],[149817600000,1492],[152496000000,1621],[155088000000,1846],[157766400000,2103],[160444800000,2137],[162864000000,2153],[165542400000,1833],[168134400000,1403],[170812800000,1288],[173404800000,1186],[176083200000,1133],[178761600000,1053],[181353600000,1347],[184032000000,1545],[186624000000,2066],[189302400000,2020],[191980800000,2750],[194486400000,2283],[197164800000,1479],[199756800000,1189],[202435200000,1160],[205027200000,1113],[207705600000,970],[210384000000,999],[212976000000,1208],[215654400000,1467],[218246400000,2059],[220924800000,2240],[223603200000,1634],[226022400000,1722],[228700800000,1801],[231292800000,1246],[233971200000,1162],[236563200000,1087],[239241600000,1013],[241920000000,959],[244512000000,1179],[247190400000,1229],[249782400000,1655],[252460800000,2019],[255139200000,2284],[257558400000,1942],[260236800000,1423],[262828800000,1340],[265507200000,1187],[268099200000,1098],[270777600000,1004],[273456000000,970],[276048000000,1140],[278726400000,1110],[281318400000,1812],[283996800000,2263],[286675200000,1820],[289094400000,1846],[291772800000,1531],[294364800000,1215],[297043200000,1075],[299635200000,1056],[302313600000,975],[304992000000,940],[307584000000,1081],[310262400000,1294],[312854400000,1341]],"name":"Male"}]},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

A more elaborated example using the `mtcars` data.



```r
hcmtcars <- highchart() %>% 
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
hcmtcars
```

<!--html_preserve--><div id="htmlwidget-6876" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-6876">{"x":{"hc_opts":{"title":{"text":"Motor Trend Car Road Tests"},"credits":{"enabled":false},"exporting":{"enabled":false},"subtitle":{"text":"Source: 1974 Motor Trend US magazine"},"xAxis":{"title":{"text":"Weight"}},"yAxis":{"title":{"text":"Miles/gallon"}},"chart":{"zoomType":"xy"},"series":[{"data":[{"x":2.62,"y":21,"z":3.9,"valuecolor":110,"color":"#26818EFF","label":"Mazda RX4"},{"x":2.875,"y":21,"z":3.9,"valuecolor":110,"color":"#26818EFF","label":"Mazda RX4 Wag"},{"x":2.32,"y":22.8,"z":3.85,"valuecolor":93,"color":"#3F4989FF","label":"Datsun 710"},{"x":3.215,"y":21.4,"z":3.08,"valuecolor":110,"color":"#26818EFF","label":"Hornet 4 Drive"},{"x":3.44,"y":18.7,"z":3.15,"valuecolor":175,"color":"#3EBC74FF","label":"Hornet Sportabout"},{"x":3.46,"y":18.1,"z":2.76,"valuecolor":105,"color":"#33628DFF","label":"Valiant"},{"x":3.57,"y":14.3,"z":3.21,"valuecolor":245,"color":"#D5E21AFF","label":"Duster 360"},{"x":3.19,"y":24.4,"z":3.69,"valuecolor":62,"color":"#48186AFF","label":"Merc 240D"},{"x":3.15,"y":22.8,"z":3.92,"valuecolor":95,"color":"#3B528BFF","label":"Merc 230"},{"x":3.44,"y":19.2,"z":3.92,"valuecolor":123,"color":"#1F978BFF","label":"Merc 280"},{"x":3.44,"y":17.8,"z":3.92,"valuecolor":123,"color":"#1F978BFF","label":"Merc 280C"},{"x":4.07,"y":16.4,"z":3.07,"valuecolor":180,"color":"#6ECE58FF","label":"Merc 450SE"},{"x":3.73,"y":17.3,"z":3.07,"valuecolor":180,"color":"#6ECE58FF","label":"Merc 450SL"},{"x":3.78,"y":15.2,"z":3.07,"valuecolor":180,"color":"#6ECE58FF","label":"Merc 450SLC"},{"x":5.25,"y":10.4,"z":2.93,"valuecolor":205,"color":"#81D34DFF","label":"Cadillac Fleetwood"},{"x":5.424,"y":10.4,"z":3,"valuecolor":215,"color":"#96D83FFF","label":"Lincoln Continental"},{"x":5.345,"y":14.7,"z":3.23,"valuecolor":230,"color":"#ABDC32FF","label":"Chrysler Imperial"},{"x":2.2,"y":32.4,"z":4.08,"valuecolor":66,"color":"#453681FF","label":"Fiat 128"},{"x":1.615,"y":30.4,"z":4.93,"valuecolor":52,"color":"#470C5FFF","label":"Honda Civic"},{"x":1.835,"y":33.9,"z":4.22,"valuecolor":65,"color":"#482273FF","label":"Toyota Corolla"},{"x":2.465,"y":21.5,"z":3.7,"valuecolor":97,"color":"#375A8CFF","label":"Toyota Corona"},{"x":3.52,"y":15.5,"z":2.76,"valuecolor":150,"color":"#21A685FF","label":"Dodge Challenger"},{"x":3.435,"y":15.2,"z":3.15,"valuecolor":150,"color":"#21A685FF","label":"AMC Javelin"},{"x":3.84,"y":13.3,"z":3.73,"valuecolor":245,"color":"#D5E21AFF","label":"Camaro Z28"},{"x":3.845,"y":19.2,"z":3.08,"valuecolor":175,"color":"#3EBC74FF","label":"Pontiac Firebird"},{"x":1.935,"y":27.3,"z":4.08,"valuecolor":66,"color":"#453681FF","label":"Fiat X1-9"},{"x":2.14,"y":26,"z":4.43,"valuecolor":91,"color":"#424086FF","label":"Porsche 914-2"},{"x":1.513,"y":30.4,"z":3.77,"valuecolor":113,"color":"#23898EFF","label":"Lotus Europa"},{"x":3.17,"y":15.8,"z":4.22,"valuecolor":264,"color":"#EAE51AFF","label":"Ford Pantera L"},{"x":2.77,"y":19.7,"z":3.62,"valuecolor":175,"color":"#3EBC74FF","label":"Ferrari Dino"},{"x":3.57,"y":15,"z":3.54,"valuecolor":335,"color":"#FDE725FF","label":"Maserati Bora"},{"x":2.78,"y":21.4,"z":4.11,"valuecolor":109,"color":"#306A8EFF","label":"Volvo 142E"}],"type":"bubble","showInLegend":false,"dataLabels":{"enabled":true,"format":"{point.label}"}}],"tooltip":{"useHTML":true,"headerFormat":"<table>","pointFormat":"<tr><th colspan=\"1\"><b>{point.label}</b></th></tr> <tr><th>Weight</th><td>{point.x} lb/1000</td></tr> <tr><th>MPG</th><td>{point.y} mpg</td></tr> <tr><th>Drat</th><td>{point.z} </td></tr> <tr><th>HP</th><td>{point.valuecolor} hp</td></tr>","footerFormat":"</table>"}},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

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
highchart(width = 400, height = 400) %>% 
  hc_title(text = "Nom! a delicious 3d pie!") %>%
  hc_subtitle(text = "your eyes hurt?") %>% 
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

<!--html_preserve--><div id="htmlwidget-2355" style="width:400px;height:400px;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-2355">{"x":{"hc_opts":{"title":{"text":"Nom! a delicious 3d pie!"},"credits":{"enabled":false},"exporting":{"enabled":false},"subtitle":{"text":"your eyes hurt?"},"chart":{"type":"pie","options3d":{"enabled":true,"alpha":70,"beta":0}},"plotOptions":{"pie":{"depth":70}},"series":[{"data":[{"name":"setosa","y":50},{"name":"versicolor","y":50},{"name":"virginica","y":50}]}]},"theme":{"chart":{"backgroundColor":null,"divBackgroundImage":"https://media.giphy.com/media/Yy26NRbpB9lDi/giphy.gif"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

### Other charts just to charting ####


```r
data("favorite_bars")
data("favorite_pies")

highchart() %>% 
  hc_title(text = "This is a bar graph describing my favorite pies
           including a pie chart describing my favorite bars") %>%
  hc_subtitle(text = "In percentage of tastiness and awesomeness") %>% 
  hc_add_serie_labels_values(favorite_pies$pie, favorite_pies$percent, name = "Pie",
                             colorByPoint = TRUE, type = "column") %>% 
  hc_add_serie_labels_values(favorite_bars$bar, favorite_bars$percent, type = "pie",
                             name = "Bar", colorByPoint = TRUE, center = c('35%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_yAxis(title = list(text = "percentage of tastiness"),
           labels = list(format = "{value}%"), max = 100) %>% 
  hc_xAxis(categories = favorite_pies$pie) %>% 
  hc_legend(enabled = FALSE) %>% 
  hc_tooltip(pointFormat = "{point.y}%")
```

<!--html_preserve--><div id="htmlwidget-9797" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-9797">{"x":{"hc_opts":{"title":{"text":"This is a bar graph describing my favorite pies\n           including a pie chart describing my favorite bars"},"credits":{"enabled":false},"exporting":{"enabled":false},"subtitle":{"text":"In percentage of tastiness and awesomeness"},"series":[{"data":[{"name":"Strawberry Rhubarb","y":85},{"name":"Pumpkin","y":64},{"name":"Lemon Meringue","y":75},{"name":"Blueberry","y":100},{"name":"Key Lime","y":57}],"name":"Pie","colorByPoint":true,"type":"column"},{"data":[{"name":"Mclaren's","y":30},{"name":"McGee's","y":28},{"name":"P & G","y":27},{"name":"White Horse Tavern","y":12},{"name":"King Cole Bar","y":3}],"type":"pie","name":"Bar","colorByPoint":true,"center":["35%","10%"],"size":100,"dataLabels":{"enabled":false}}],"yAxis":{"title":{"text":"percentage of tastiness"},"labels":{"format":"{value}%"},"max":100},"xAxis":{"categories":["Strawberry Rhubarb","Pumpkin","Lemon Meringue","Blueberry","Key Lime"]},"legend":{"enabled":false},"tooltip":{"pointFormat":"{point.y}%"}},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->


---
title: "readme.R"
author: "jkunst"
date: "Wed Jan 13 18:21:17 2016"
---
