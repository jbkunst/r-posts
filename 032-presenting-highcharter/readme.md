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
to get the chart.

With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?** 
The main reasons were/are:

- Write/code highcharts plots using the piping style and get similar results like 
[dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
[taucharts](http://rpubs.com/hrbrmstr/taucharts), [leaflet](https://rstudio.github.io/leaflet/)
packages.
- Get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts). This means 
make a not so useR-friendly wrapper in the sense that you maybe need to make/construct 
the chart specifying paramter by parameter (just like highcharts). But don't worry, there are 
some *shortcuts* functions to plot some R objects on the fly (see the examples below).
- Include and create [*themes*](http://jkunst.com/highcharter/#themes) :D.
- Put all my love for highcharts in somewhere.

### Some Q&A ####

**When use this package?** I recommend use this when you have fihinsh your analysis and you want
to show your result with some interactivity. So, before use experimental plot to visualize, explore
the data with **ggplot2** then use **highcharter** as one of the various alternatives what we have
in ou*R* community like ggivs, dygraphs, taucharts, metricsgraphics, plotly among others 
(please check hafen's [htmlwidgets gallery](http://hafen.github.io/htmlwidgetsgallery/))

**What are the advantages of using this package?** Basically the advantages are inherited from
highcharts: have a numerous chart types with the **same** format, style, flavour. I think in a
situation when you use a treemap and a scatter chart from differents packages in a shiny app.
Other advantage is the posibility to create or modify themes (I like this a lot!) and 
customize in every way your chart: beatiful tooltips, titles, credits, legends, [add plotlines or 
plotbands](http://jkunst.com/highcharter/#hc_xaxis-and-hc_yaxis).

**What are the disadvantages of this package and highcharts?** One thing I miss is the facet 
implementation like in taucharts and hrbrmstr's [taucharts](http://rpubs.com/hrbrmstr/taucharts).
This is not really necesary but it's really good when a visualization library has it. Maybe 
other disadvantage of *this* implmentation is the functions use standar evaluation 
`plot(data$x, data$y)` instead something more direct like `plot(data, ~x, ~y)`. That's why
I recommed this package to make the final chart instead use the package to explorer visually
the data.

### The Hellow World chart ####

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

<!--html_preserve--><div id="htmlwidget-6751" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-6751">{"x":{"hc_opts":{"title":{"text":null},"credits":{"enabled":false},"exporting":{"enabled":false},"series":[{"name":"tokyo","data":[7,6.9,9.5,14.5,18.2,21.5,25.2,26.5,23.3,18.3,13.9,9.6]}]},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

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

<!--html_preserve--><div id="htmlwidget-7820" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-7820">{"x":{"hc_opts":{"title":{"text":"Temperatures for some cities"},"credits":{"enabled":false},"exporting":{"enabled":false},"series":[{"name":"tokyo","data":[7,6.9,9.5,14.5,18.2,21.5,25.2,26.5,23.3,18.3,13.9,9.6]},{"name":"London","data":[3.9,4.2,5.7,8.5,11.9,15.2,17,16.6,14.2,10.3,6.6,4.8],"dataLabels":{"enabled":true}},{"name":"New York","data":[-0.2,0.8,5.7,11.3,17,22,24.8,24.1,20.1,14.1,8.6,2.5],"type":"spline"}],"xAxis":{"categories":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]},"yAxis":{"title":{"text":"Temperature"},"labels":{"format":"{value}? C"}}},"theme":{"colors":["#f45b5b","#8085e9","#8d4654","#7798BF","#aaeeee","#ff0066","#eeaaee","#55BF3B","#DF5353","#7798BF","#aaeeee"],"chart":{"backgroundColor":null,"divBackgroundImage":"http://www.highcharts.com/samples/graphics/sand.png","style":{"fontFamily":"Signika, serif"}},"title":{"style":{"color":"black","fontSize":"16px","fontWeight":"bold"}},"subtitle":{"style":{"color":"black"}},"tooltip":{"borderWidth":0},"legend":{"itemStyle":{"fontWeight":"bold","fontSize":"13px"}},"xAxis":{"labels":{"style":{"color":"#6e6e70"}}},"yAxis":{"labels":{"style":{"color":"#6e6e70"}}},"plotOptions":{"series":{"shadow":false},"candlestick":{"lineColor":"#404048"},"map":{"shadow":false}},"navigator":{"xAxis":{"gridLineColor":"#D0D0D8"}},"rangeSelector":{"buttonTheme":{"fill":"white","stroke":"#C0C0C8","stroke-width":1,"states":{"select":{"fill":"#D0D0D8"}}}},"scrollbar":{"trackBorderColor":"#C0C0C8"},"background2":"#E0E0E8"},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":"Signika"},"evals":[]}</script><!--/html_preserve-->

Now what can you do with a little extra effort:



```r
library("httr")
library("purrr")
swmovies <- content(GET("http://swapi.co/api/films/?format=json"))

swdata <- map_df(swmovies$results, function(x){
  data_frame(title = x$title,
             species = length(x$species),
             planets = length(x$planets),
             release = x$release_date)
}) %>% arrange(release)

swdata 
```

```
## Source: local data frame [7 x 4]
## 
##                     title species planets    release
##                     (chr)   (int)   (int)      (chr)
## 1              A New Hope       5       3 1977-05-25
## 2 The Empire Strikes Back       5       4 1980-05-17
## 3      Return of the Jedi       9       5 1983-05-25
## 4      The Phantom Menace      20       3 1999-05-19
## 5    Attack of the Clones      14       5 2002-05-16
## 6     Revenge of the Sith      20      13 2005-05-19
## 7       The Force Awakens       3       1 2015-12-11
```

```r
swthm <- hc_theme_merge(
  hc_theme_darkunica(),
  hc_theme(
    credits = list(
      style = list(
        color = "#4bd5ee"
      )
    ),
    title = list(
      style = list(
        color = "#4bd5ee"
        )
      ),
    chart = list(
      backgroundColor = "transparent",
      divBackgroundImage = "http://www.wired.com/images_blogs/underwire/2013/02/xwing-bg.gif",
      style = list(fontFamily = "Lato")
    )
  )
)

highchart() %>% 
  hc_add_theme(swthm) %>% 
  hc_xAxis(categories = swdata$title,
           title = list(text = "Movie")) %>% 
  hc_yAxis(title = list(text = "Number")) %>% 
  hc_add_serie(data = swdata$species, name = "Species",
               type = "column", color = "#e5b13a") %>% 
  hc_add_serie(data = swdata$planets, name = "Planets",
               type = "column", color = "#4bd5ee") %>%
  hc_title(text = "Diversity in <span style=\"color:#e5b13a\">
           STAR WARS</span> movies",
           useHTML = TRUE) %>% 
  hc_credits(enabled = TRUE, text = "Source: SWAPI",
             href = "https://swapi.co/",
             style = list(fontSize = "12px"))
```

<!--html_preserve--><div id="htmlwidget-2939" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-2939">{"x":{"hc_opts":{"title":{"text":"Diversity in <span style=\"color:#e5b13a\">\n           STAR WARS</span> movies","useHTML":true},"credits":{"enabled":true,"text":"Source: SWAPI","href":"https://swapi.co/","style":{"fontSize":"12px"}},"exporting":{"enabled":false},"xAxis":{"categories":["A New Hope","The Empire Strikes Back","Return of the Jedi","The Phantom Menace","Attack of the Clones","Revenge of the Sith","The Force Awakens"],"title":{"text":"Movie"}},"yAxis":{"title":{"text":"Number"}},"series":[{"data":[5,5,9,20,14,20,3],"name":"Species","type":"column","color":"#e5b13a"},{"data":[3,4,5,3,5,13,1],"name":"Planets","type":"column","color":"#4bd5ee"}]},"theme":{"colors":["#2b908f","#90ee7e","#f45b5b","#7798BF","#aaeeee","#ff0066","#eeaaee","#55BF3B","#DF5353","#7798BF","#aaeeee"],"chart":{"backgroundColor":"transparent","style":{"fontFamily":"Lato"},"plotBorderColor":"#606063","divBackgroundImage":"http://www.wired.com/images_blogs/underwire/2013/02/xwing-bg.gif"},"title":{"style":{"color":"#4bd5ee","textTransform":"uppercase","fontSize":"20px"}},"subtitle":{"style":{"color":"#E0E0E3","textTransform":"uppercase"}},"xAxis":{"gridLineColor":"#707073","labels":{"style":{"color":"#E0E0E3"}},"lineColor":"#707073","minorGridLineColor":"#505053","tickColor":"#707073","title":{"style":{"color":"#A0A0A3"}}},"yAxis":{"gridLineColor":"#707073","labels":{"style":{"color":"#E0E0E3"}},"lineColor":"#707073","minorGridLineColor":"#505053","tickColor":"#707073","tickWidth":1,"title":{"style":{"color":"#A0A0A3"}}},"tooltip":{"backgroundColor":"rgba(0, 0, 0, 0.85)","style":{"color":"#F0F0F0"}},"plotOptions":{"series":{"dataLabels":{"color":"#B0B0B3"},"marker":{"lineColor":"#333"}},"boxplot":{"fillColor":"#505053"},"candlestick":{"lineColor":"white"},"errorbar":{"color":"white"}},"legend":{"itemStyle":{"color":"#E0E0E3"},"itemHoverStyle":{"color":"#FFF"},"itemHiddenStyle":{"color":"#606063"}},"credits":{"style":{"color":"#4bd5ee"}},"labels":{"style":{"color":"#707073"}},"drilldown":{"activeAxisLabelStyle":{"color":"#F0F0F3"},"activeDataLabelStyle":{"color":"#F0F0F3"}},"navigation":{"buttonOptions":{"symbolStroke":"#DDDDDD","theme":{"fill":"#505053"}}},"rangeSelector":{"buttonTheme":{"fill":"#505053","stroke":"#000000","style":{"color":"#CCC"},"states":{"hover":{"fill":"#707073","stroke":"#000000","style":{"color":"white"}},"select":{"fill":"#000003","stroke":"#000000","style":{"color":"white"}}}},"inputBoxBorderColor":"#505053","inputStyle":{"backgroundColor":"#333","color":"silver"},"labelStyle":{"color":"silver"}},"navigator":{"handles":{"backgroundColor":"#666","borderColor":"#AAA"},"outlineColor":"#CCC","maskFill":"rgba(255,255,255,0.1)","series":{"color":"#7798BF","lineColor":"#A6C7ED"},"xAxis":{"gridLineColor":"#505053"}},"scrollbar":{"barBackgroundColor":"#808083","barBorderColor":"#808083","buttonArrowColor":"#CCC","buttonBackgroundColor":"#606063","buttonBorderColor":"#606063","rifleColor":"#FFF","trackBackgroundColor":"#404043","trackBorderColor":"#404043"},"legendBackgroundColor":"rgba(0, 0, 0, 0.5)","background2":"#505053","dataLabelsColor":"#B0B0B3","textColor":"#C0C0C0","contrastTextColor":"#F0F0F3","maskColor":"rgba(255,255,255,0.3)"},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":"Lato"},"evals":[]}</script><!--/html_preserve-->

### More Examples ####
For ts objects. Compare this example with the [dygrapths](https://rstudio.github.io/dygraphs/)
one


```r
highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") 
```

<!--html_preserve--><div id="htmlwidget-2614" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-2614">{"x":{"hc_opts":{"title":{"text":"Monthly Deaths from Lung Diseases in the UK"},"credits":{"enabled":false},"exporting":{"enabled":false},"xAxis":{"type":"datetime"},"series":[{"marker":{"enabled":false},"data":[[126230400000,901],[128908800000,689],[131328000000,827],[134006400000,677],[136598400000,522],[139276800000,406],[141868800000,441],[144547200000,393],[147225600000,387],[149817600000,582],[152496000000,578],[155088000000,666],[157766400000,830],[160444800000,752],[162864000000,785],[165542400000,664],[168134400000,467],[170812800000,438],[173404800000,421],[176083200000,412],[178761600000,343],[181353600000,440],[184032000000,531],[186624000000,771],[189302400000,767],[191980800000,1141],[194486400000,896],[197164800000,532],[199756800000,447],[202435200000,420],[205027200000,376],[207705600000,330],[210384000000,357],[212976000000,445],[215654400000,546],[218246400000,764],[220924800000,862],[223603200000,660],[226022400000,663],[228700800000,643],[231292800000,502],[233971200000,392],[236563200000,411],[239241600000,348],[241920000000,387],[244512000000,385],[247190400000,411],[249782400000,638],[252460800000,796],[255139200000,853],[257558400000,737],[260236800000,546],[262828800000,530],[265507200000,446],[268099200000,431],[270777600000,362],[273456000000,387],[276048000000,430],[278726400000,425],[281318400000,679],[283996800000,821],[286675200000,785],[289094400000,727],[291772800000,612],[294364800000,478],[297043200000,429],[299635200000,405],[302313600000,379],[304992000000,393],[307584000000,411],[310262400000,487],[312854400000,574]],"name":"Female"},{"marker":{"enabled":false},"data":[[126230400000,2134],[128908800000,1863],[131328000000,1877],[134006400000,1877],[136598400000,1492],[139276800000,1249],[141868800000,1280],[144547200000,1131],[147225600000,1209],[149817600000,1492],[152496000000,1621],[155088000000,1846],[157766400000,2103],[160444800000,2137],[162864000000,2153],[165542400000,1833],[168134400000,1403],[170812800000,1288],[173404800000,1186],[176083200000,1133],[178761600000,1053],[181353600000,1347],[184032000000,1545],[186624000000,2066],[189302400000,2020],[191980800000,2750],[194486400000,2283],[197164800000,1479],[199756800000,1189],[202435200000,1160],[205027200000,1113],[207705600000,970],[210384000000,999],[212976000000,1208],[215654400000,1467],[218246400000,2059],[220924800000,2240],[223603200000,1634],[226022400000,1722],[228700800000,1801],[231292800000,1246],[233971200000,1162],[236563200000,1087],[239241600000,1013],[241920000000,959],[244512000000,1179],[247190400000,1229],[249782400000,1655],[252460800000,2019],[255139200000,2284],[257558400000,1942],[260236800000,1423],[262828800000,1340],[265507200000,1187],[268099200000,1098],[270777600000,1004],[273456000000,970],[276048000000,1140],[278726400000,1110],[281318400000,1812],[283996800000,2263],[286675200000,1820],[289094400000,1846],[291772800000,1531],[294364800000,1215],[297043200000,1075],[299635200000,1056],[302313600000,975],[304992000000,940],[307584000000,1081],[310262400000,1294],[312854400000,1341]],"name":"Male"}]},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->


A more elaborated example using the `mtcars` data. And it's nice like 
[juba's scatterD3](https://github.com/juba/scatterD3).



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

<!--html_preserve--><div id="htmlwidget-6402" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-6402">{"x":{"hc_opts":{"title":{"text":"Motor Trend Car Road Tests"},"credits":{"enabled":false},"exporting":{"enabled":false},"subtitle":{"text":"Source: 1974 Motor Trend US magazine"},"xAxis":{"title":{"text":"Weight"}},"yAxis":{"title":{"text":"Miles/gallon"}},"chart":{"zoomType":"xy"},"series":[{"data":[{"x":2.62,"y":21,"z":3.9,"valuecolor":110,"color":"#26818EFF","label":"Mazda RX4"},{"x":2.875,"y":21,"z":3.9,"valuecolor":110,"color":"#26818EFF","label":"Mazda RX4 Wag"},{"x":2.32,"y":22.8,"z":3.85,"valuecolor":93,"color":"#3F4989FF","label":"Datsun 710"},{"x":3.215,"y":21.4,"z":3.08,"valuecolor":110,"color":"#26818EFF","label":"Hornet 4 Drive"},{"x":3.44,"y":18.7,"z":3.15,"valuecolor":175,"color":"#3EBC74FF","label":"Hornet Sportabout"},{"x":3.46,"y":18.1,"z":2.76,"valuecolor":105,"color":"#33628DFF","label":"Valiant"},{"x":3.57,"y":14.3,"z":3.21,"valuecolor":245,"color":"#D5E21AFF","label":"Duster 360"},{"x":3.19,"y":24.4,"z":3.69,"valuecolor":62,"color":"#48186AFF","label":"Merc 240D"},{"x":3.15,"y":22.8,"z":3.92,"valuecolor":95,"color":"#3B528BFF","label":"Merc 230"},{"x":3.44,"y":19.2,"z":3.92,"valuecolor":123,"color":"#1F978BFF","label":"Merc 280"},{"x":3.44,"y":17.8,"z":3.92,"valuecolor":123,"color":"#1F978BFF","label":"Merc 280C"},{"x":4.07,"y":16.4,"z":3.07,"valuecolor":180,"color":"#6ECE58FF","label":"Merc 450SE"},{"x":3.73,"y":17.3,"z":3.07,"valuecolor":180,"color":"#6ECE58FF","label":"Merc 450SL"},{"x":3.78,"y":15.2,"z":3.07,"valuecolor":180,"color":"#6ECE58FF","label":"Merc 450SLC"},{"x":5.25,"y":10.4,"z":2.93,"valuecolor":205,"color":"#81D34DFF","label":"Cadillac Fleetwood"},{"x":5.424,"y":10.4,"z":3,"valuecolor":215,"color":"#96D83FFF","label":"Lincoln Continental"},{"x":5.345,"y":14.7,"z":3.23,"valuecolor":230,"color":"#ABDC32FF","label":"Chrysler Imperial"},{"x":2.2,"y":32.4,"z":4.08,"valuecolor":66,"color":"#453681FF","label":"Fiat 128"},{"x":1.615,"y":30.4,"z":4.93,"valuecolor":52,"color":"#470C5FFF","label":"Honda Civic"},{"x":1.835,"y":33.9,"z":4.22,"valuecolor":65,"color":"#482273FF","label":"Toyota Corolla"},{"x":2.465,"y":21.5,"z":3.7,"valuecolor":97,"color":"#375A8CFF","label":"Toyota Corona"},{"x":3.52,"y":15.5,"z":2.76,"valuecolor":150,"color":"#21A685FF","label":"Dodge Challenger"},{"x":3.435,"y":15.2,"z":3.15,"valuecolor":150,"color":"#21A685FF","label":"AMC Javelin"},{"x":3.84,"y":13.3,"z":3.73,"valuecolor":245,"color":"#D5E21AFF","label":"Camaro Z28"},{"x":3.845,"y":19.2,"z":3.08,"valuecolor":175,"color":"#3EBC74FF","label":"Pontiac Firebird"},{"x":1.935,"y":27.3,"z":4.08,"valuecolor":66,"color":"#453681FF","label":"Fiat X1-9"},{"x":2.14,"y":26,"z":4.43,"valuecolor":91,"color":"#424086FF","label":"Porsche 914-2"},{"x":1.513,"y":30.4,"z":3.77,"valuecolor":113,"color":"#23898EFF","label":"Lotus Europa"},{"x":3.17,"y":15.8,"z":4.22,"valuecolor":264,"color":"#EAE51AFF","label":"Ford Pantera L"},{"x":2.77,"y":19.7,"z":3.62,"valuecolor":175,"color":"#3EBC74FF","label":"Ferrari Dino"},{"x":3.57,"y":15,"z":3.54,"valuecolor":335,"color":"#FDE725FF","label":"Maserati Bora"},{"x":2.78,"y":21.4,"z":4.11,"valuecolor":109,"color":"#306A8EFF","label":"Volvo 142E"}],"type":"bubble","showInLegend":false,"dataLabels":{"enabled":true,"format":"{point.label}"}}],"tooltip":{"useHTML":true,"headerFormat":"<table>","pointFormat":"<tr><th colspan=\"1\"><b>{point.label}</b></th></tr> <tr><th>Weight</th><td>{point.x} lb/1000</td></tr> <tr><th>MPG</th><td>{point.y} mpg</td></tr> <tr><th>Drat</th><td>{point.z} </td></tr> <tr><th>HP</th><td>{point.valuecolor} hp</td></tr>","footerFormat":"</table>"}},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

Let's try treemaps


```r
library("treemap")
library("viridisLite")

data(GNI2010)
```

```r
tm <- treemap(GNI2010, index = c("continent", "iso3"),
              vSize = "population", vColor = "GNI",
              type = "value", palette = viridis(6))


hc_tm <- highchart(height = 800) %>% 
  hc_add_serie_treemap(tm, allowDrillToNode = TRUE,
                       layoutAlgorithm = "squarified",
                       name = "tmdata") %>% 
  hc_title(text = "Gross National Income World Data") %>% 
  hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
             Pop: {point.value:,.0f}<br>
             GNI: {point.valuecolor:,.0f}")

hc_tm
```

<!--html_preserve--><div id="htmlwidget-8945" style="width:100%;height:800px;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-8945">{"x":{"hc_opts":{"title":{"text":"Gross National Income World Data"},"credits":{"enabled":false},"exporting":{"enabled":false},"series":[{"data":[{"name":"Africa","iso3":null,"value":954502,"valuecolor":106410,"level":1,"color":"#FDE725","id":"africa","continent":null},{"name":"Asia","iso3":null,"value":4138122,"valuecolor":285410,"level":1,"color":"#FDE725","id":"asia","continent":null},{"name":"Europe","iso3":null,"value":714837,"valuecolor":1056360,"level":1,"color":"#FDE725","id":"europe","continent":null},{"name":"North America","iso3":null,"value":540446,"valuecolor":240850,"level":1,"color":"#FDE725","id":"north_america","continent":null},{"name":"Oceania","iso3":null,"value":36572,"valuecolor":80770,"level":1,"color":"#E2E22D","id":"oceania","continent":null},{"name":"South America","iso3":null,"value":392162,"valuecolor":71410,"level":1,"color":"#BBDC3B","id":"south_america","continent":null},{"name":"AGO","iso3":null,"value":19082,"valuecolor":3960,"level":2,"color":"#259488","id":"ago","parent":"africa","continent":"Africa"},{"name":"BDI","iso3":null,"value":8382,"valuecolor":170,"level":2,"color":"#269089","id":"bdi","parent":"africa","continent":"Africa"},{"name":"BEN","iso3":null,"value":8850,"valuecolor":780,"level":2,"color":"#269089","id":"ben","parent":"africa","continent":"Africa"},{"name":"BFA","iso3":null,"value":16468,"valuecolor":550,"level":2,"color":"#269089","id":"bfa","parent":"africa","continent":"Africa"},{"name":"BWA","iso3":null,"value":2007,"valuecolor":6740,"level":2,"color":"#249787","id":"bwa","parent":"africa","continent":"Africa"},{"name":"CAF","iso3":null,"value":4401,"valuecolor":470,"level":2,"color":"#269089","id":"caf","parent":"africa","continent":"Africa"},{"name":"CIV","iso3":null,"value":19738,"valuecolor":1160,"level":2,"color":"#269089","id":"civ","parent":"africa","continent":"Africa"},{"name":"CMR","iso3":null,"value":19599,"valuecolor":1200,"level":2,"color":"#269089","id":"cmr","parent":"africa","continent":"Africa"},{"name":"COG","iso3":null,"value":4043,"valuecolor":2240,"level":2,"color":"#259288","id":"cog","parent":"africa","continent":"Africa"},{"name":"COM","iso3":null,"value":735,"valuecolor":750,"level":2,"color":"#269089","id":"com","parent":"africa","continent":"Africa"},{"name":"CPV","iso3":null,"value":496,"valuecolor":3270,"level":2,"color":"#259288","id":"cpv","parent":"africa","continent":"Africa"},{"name":"DJI","iso3":null,"value":889,"valuecolor":0,"level":2,"color":"#269089","id":"dji","parent":"africa","continent":"Africa"},{"name":"DZA","iso3":null,"value":35468,"valuecolor":4390,"level":2,"color":"#259488","id":"dza","parent":"africa","continent":"Africa"},{"name":"EGY","iso3":null,"value":81121,"valuecolor":2420,"level":2,"color":"#259288","id":"egy","parent":"africa","continent":"Africa"},{"name":"ERI","iso3":null,"value":5254,"valuecolor":340,"level":2,"color":"#269089","id":"eri","parent":"africa","continent":"Africa"},{"name":"ETH","iso3":null,"value":82950,"valuecolor":390,"level":2,"color":"#269089","id":"eth","parent":"africa","continent":"Africa"},{"name":"GAB","iso3":null,"value":1505,"valuecolor":7650,"level":2,"color":"#249987","id":"gab","parent":"africa","continent":"Africa"},{"name":"GHA","iso3":null,"value":24392,"valuecolor":1250,"level":2,"color":"#269089","id":"gha","parent":"africa","continent":"Africa"},{"name":"GIN","iso3":null,"value":9982,"valuecolor":400,"level":2,"color":"#269089","id":"gin","parent":"africa","continent":"Africa"},{"name":"GMB","iso3":null,"value":1729,"valuecolor":450,"level":2,"color":"#269089","id":"gmb","parent":"africa","continent":"Africa"},{"name":"GNB","iso3":null,"value":1515,"valuecolor":590,"level":2,"color":"#269089","id":"gnb","parent":"africa","continent":"Africa"},{"name":"GNQ","iso3":null,"value":700,"valuecolor":14550,"level":2,"color":"#22A385","id":"gnq","parent":"africa","continent":"Africa"},{"name":"KEN","iso3":null,"value":40513,"valuecolor":810,"level":2,"color":"#269089","id":"ken","parent":"africa","continent":"Africa"},{"name":"LBR","iso3":null,"value":3994,"valuecolor":200,"level":2,"color":"#269089","id":"lbr","parent":"africa","continent":"Africa"},{"name":"LBY","iso3":null,"value":6355,"valuecolor":0,"level":2,"color":"#269089","id":"lby","parent":"africa","continent":"Africa"},{"name":"LSO","iso3":null,"value":2171,"valuecolor":1090,"level":2,"color":"#269089","id":"lso","parent":"africa","continent":"Africa"},{"name":"MAR","iso3":null,"value":31951,"valuecolor":2850,"level":2,"color":"#259288","id":"mar","parent":"africa","continent":"Africa"},{"name":"MDG","iso3":null,"value":20714,"valuecolor":430,"level":2,"color":"#269089","id":"mdg","parent":"africa","continent":"Africa"},{"name":"MLI","iso3":null,"value":15370,"valuecolor":600,"level":2,"color":"#269089","id":"mli","parent":"africa","continent":"Africa"},{"name":"MOZ","iso3":null,"value":23390,"valuecolor":440,"level":2,"color":"#269089","id":"moz","parent":"africa","continent":"Africa"},{"name":"MRT","iso3":null,"value":3460,"valuecolor":1000,"level":2,"color":"#269089","id":"mrt","parent":"africa","continent":"Africa"},{"name":"MUS","iso3":null,"value":1281,"valuecolor":7850,"level":2,"color":"#249987","id":"mus","parent":"africa","continent":"Africa"},{"name":"MWI","iso3":null,"value":14901,"valuecolor":330,"level":2,"color":"#269089","id":"mwi","parent":"africa","continent":"Africa"},{"name":"MYT","iso3":null,"value":204,"valuecolor":0,"level":2,"color":"#269089","id":"myt","parent":"africa","continent":"Africa"},{"name":"NAM","iso3":null,"value":2283,"valuecolor":4510,"level":2,"color":"#259488","id":"nam","parent":"africa","continent":"Africa"},{"name":"NER","iso3":null,"value":15512,"valuecolor":370,"level":2,"color":"#269089","id":"ner","parent":"africa","continent":"Africa"},{"name":"NGA","iso3":null,"value":158423,"valuecolor":1230,"level":2,"color":"#269089","id":"nga","parent":"africa","continent":"Africa"},{"name":"RWA","iso3":null,"value":10624,"valuecolor":520,"level":2,"color":"#269089","id":"rwa","parent":"africa","continent":"Africa"},{"name":"SDN","iso3":null,"value":43552,"valuecolor":1270,"level":2,"color":"#269089","id":"sdn","parent":"africa","continent":"Africa"},{"name":"SEN","iso3":null,"value":12434,"valuecolor":1080,"level":2,"color":"#269089","id":"sen","parent":"africa","continent":"Africa"},{"name":"SLE","iso3":null,"value":5867,"valuecolor":340,"level":2,"color":"#269089","id":"sle","parent":"africa","continent":"Africa"},{"name":"SOM","iso3":null,"value":9331,"valuecolor":0,"level":2,"color":"#269089","id":"som","parent":"africa","continent":"Africa"},{"name":"STP","iso3":null,"value":165,"valuecolor":1200,"level":2,"color":"#269089","id":"stp","parent":"africa","continent":"Africa"},{"name":"SWZ","iso3":null,"value":1056,"valuecolor":2930,"level":2,"color":"#259288","id":"swz","parent":"africa","continent":"Africa"},{"name":"SYC","iso3":null,"value":87,"valuecolor":9710,"level":2,"color":"#249B86","id":"syc","parent":"africa","continent":"Africa"},{"name":"TCD","iso3":null,"value":11227,"valuecolor":620,"level":2,"color":"#269089","id":"tcd","parent":"africa","continent":"Africa"},{"name":"TGO","iso3":null,"value":6028,"valuecolor":490,"level":2,"color":"#269089","id":"tgo","parent":"africa","continent":"Africa"},{"name":"TUN","iso3":null,"value":10549,"valuecolor":4160,"level":2,"color":"#259488","id":"tun","parent":"africa","continent":"Africa"},{"name":"TZA","iso3":null,"value":44841,"valuecolor":540,"level":2,"color":"#269089","id":"tza","parent":"africa","continent":"Africa"},{"name":"UGA","iso3":null,"value":33424,"valuecolor":500,"level":2,"color":"#269089","id":"uga","parent":"africa","continent":"Africa"},{"name":"ZAF","iso3":null,"value":49991,"valuecolor":6090,"level":2,"color":"#249787","id":"zaf","parent":"africa","continent":"Africa"},{"name":"ZMB","iso3":null,"value":12927,"valuecolor":1070,"level":2,"color":"#269089","id":"zmb","parent":"africa","continent":"Africa"},{"name":"ZWE","iso3":null,"value":12571,"valuecolor":460,"level":2,"color":"#269089","id":"zwe","parent":"africa","continent":"Africa"},{"name":"AFG","iso3":null,"value":34385,"valuecolor":410,"level":2,"color":"#269089","id":"afg","parent":"asia","continent":"Asia"},{"name":"ARE","iso3":null,"value":7512,"valuecolor":0,"level":2,"color":"#269089","id":"are","parent":"asia","continent":"Asia"},{"name":"ARM","iso3":null,"value":3092,"valuecolor":3200,"level":2,"color":"#259288","id":"arm","parent":"asia","continent":"Asia"},{"name":"AZE","iso3":null,"value":9054,"valuecolor":5330,"level":2,"color":"#249787","id":"aze","parent":"asia","continent":"Asia"},{"name":"BGD","iso3":null,"value":148692,"valuecolor":700,"level":2,"color":"#269089","id":"bgd","parent":"asia","continent":"Asia"},{"name":"BHR","iso3":null,"value":1262,"valuecolor":0,"level":2,"color":"#269089","id":"bhr","parent":"asia","continent":"Asia"},{"name":"BRN","iso3":null,"value":399,"valuecolor":0,"level":2,"color":"#269089","id":"brn","parent":"asia","continent":"Asia"},{"name":"BTN","iso3":null,"value":726,"valuecolor":1870,"level":2,"color":"#259288","id":"btn","parent":"asia","continent":"Asia"},{"name":"CHN","iso3":null,"value":1338300,"valuecolor":4270,"level":2,"color":"#259488","id":"chn","parent":"asia","continent":"Asia"},{"name":"CYP","iso3":null,"value":1103,"valuecolor":29430,"level":2,"color":"#3CB474","id":"cyp","parent":"asia","continent":"Asia"},{"name":"GEO","iso3":null,"value":4452,"valuecolor":2690,"level":2,"color":"#259288","id":"geo","parent":"asia","continent":"Asia"},{"name":"HKG","iso3":null,"value":7068,"valuecolor":32780,"level":2,"color":"#45B86F","id":"hkg","parent":"asia","continent":"Asia"},{"name":"IDN","iso3":null,"value":239870,"valuecolor":2500,"level":2,"color":"#259288","id":"idn","parent":"asia","continent":"Asia"},{"name":"IND","iso3":null,"value":1224615,"valuecolor":1270,"level":2,"color":"#269089","id":"ind","parent":"asia","continent":"Asia"},{"name":"IRN","iso3":null,"value":73973,"valuecolor":0,"level":2,"color":"#269089","id":"irn","parent":"asia","continent":"Asia"},{"name":"IRQ","iso3":null,"value":32031,"valuecolor":2340,"level":2,"color":"#259288","id":"irq","parent":"asia","continent":"Asia"},{"name":"ISR","iso3":null,"value":7624,"valuecolor":27180,"level":2,"color":"#37B277","id":"isr","parent":"asia","continent":"Asia"},{"name":"JOR","iso3":null,"value":6047,"valuecolor":4340,"level":2,"color":"#259488","id":"jor","parent":"asia","continent":"Asia"},{"name":"JPN","iso3":null,"value":127451,"valuecolor":41850,"level":2,"color":"#5BC262","id":"jpn","parent":"asia","continent":"Asia"},{"name":"KAZ","iso3":null,"value":16323,"valuecolor":7580,"level":2,"color":"#249987","id":"kaz","parent":"asia","continent":"Asia"},{"name":"KGZ","iso3":null,"value":5448,"valuecolor":830,"level":2,"color":"#269089","id":"kgz","parent":"asia","continent":"Asia"},{"name":"KHM","iso3":null,"value":14139,"valuecolor":750,"level":2,"color":"#269089","id":"khm","parent":"asia","continent":"Asia"},{"name":"KOR","iso3":null,"value":48875,"valuecolor":19890,"level":2,"color":"#26AA81","id":"kor","parent":"asia","continent":"Asia"},{"name":"KWT","iso3":null,"value":2736,"valuecolor":0,"level":2,"color":"#269089","id":"kwt","parent":"asia","continent":"Asia"},{"name":"LAO","iso3":null,"value":6201,"valuecolor":1040,"level":2,"color":"#269089","id":"lao","parent":"asia","continent":"Asia"},{"name":"LBN","iso3":null,"value":4227,"valuecolor":8880,"level":2,"color":"#249B86","id":"lbn","parent":"asia","continent":"Asia"},{"name":"LKA","iso3":null,"value":20860,"valuecolor":2240,"level":2,"color":"#259288","id":"lka","parent":"asia","continent":"Asia"},{"name":"MAC","iso3":null,"value":544,"valuecolor":0,"level":2,"color":"#269089","id":"mac","parent":"asia","continent":"Asia"},{"name":"MDV","iso3":null,"value":316,"valuecolor":5750,"level":2,"color":"#249787","id":"mdv","parent":"asia","continent":"Asia"},{"name":"MMR","iso3":null,"value":47963,"valuecolor":0,"level":2,"color":"#269089","id":"mmr","parent":"asia","continent":"Asia"},{"name":"MNG","iso3":null,"value":2756,"valuecolor":1870,"level":2,"color":"#259288","id":"mng","parent":"asia","continent":"Asia"},{"name":"MYS","iso3":null,"value":28401,"valuecolor":7760,"level":2,"color":"#249987","id":"mys","parent":"asia","continent":"Asia"},{"name":"NPL","iso3":null,"value":29959,"valuecolor":490,"level":2,"color":"#269089","id":"npl","parent":"asia","continent":"Asia"},{"name":"OMN","iso3":null,"value":2783,"valuecolor":0,"level":2,"color":"#269089","id":"omn","parent":"asia","continent":"Asia"},{"name":"PAK","iso3":null,"value":173593,"valuecolor":1050,"level":2,"color":"#269089","id":"pak","parent":"asia","continent":"Asia"},{"name":"PHL","iso3":null,"value":93261,"valuecolor":2060,"level":2,"color":"#259288","id":"phl","parent":"asia","continent":"Asia"},{"name":"PRK","iso3":null,"value":24346,"valuecolor":0,"level":2,"color":"#269089","id":"prk","parent":"asia","continent":"Asia"},{"name":"QAT","iso3":null,"value":1759,"valuecolor":0,"level":2,"color":"#269089","id":"qat","parent":"asia","continent":"Asia"},{"name":"SAU","iso3":null,"value":27448,"valuecolor":0,"level":2,"color":"#269089","id":"sau","parent":"asia","continent":"Asia"},{"name":"SGP","iso3":null,"value":5077,"valuecolor":40070,"level":2,"color":"#56C065","id":"sgp","parent":"asia","continent":"Asia"},{"name":"SYR","iso3":null,"value":20447,"valuecolor":2750,"level":2,"color":"#259288","id":"syr","parent":"asia","continent":"Asia"},{"name":"THA","iso3":null,"value":69122,"valuecolor":4150,"level":2,"color":"#259488","id":"tha","parent":"asia","continent":"Asia"},{"name":"TJK","iso3":null,"value":6879,"valuecolor":800,"level":2,"color":"#269089","id":"tjk","parent":"asia","continent":"Asia"},{"name":"TKM","iso3":null,"value":5042,"valuecolor":3790,"level":2,"color":"#259488","id":"tkm","parent":"asia","continent":"Asia"},{"name":"TUR","iso3":null,"value":72752,"valuecolor":9890,"level":2,"color":"#249B86","id":"tur","parent":"asia","continent":"Asia"},{"name":"UZB","iso3":null,"value":28228,"valuecolor":1280,"level":2,"color":"#269089","id":"uzb","parent":"asia","continent":"Asia"},{"name":"VNM","iso3":null,"value":86928,"valuecolor":1160,"level":2,"color":"#269089","id":"vnm","parent":"asia","continent":"Asia"},{"name":"YEM","iso3":null,"value":24053,"valuecolor":1170,"level":2,"color":"#269089","id":"yem","parent":"asia","continent":"Asia"},{"name":"ALB","iso3":null,"value":3205,"valuecolor":3960,"level":2,"color":"#259488","id":"alb","parent":"europe","continent":"Europe"},{"name":"AUT","iso3":null,"value":8390,"valuecolor":47030,"level":2,"color":"#68C85B","id":"aut","parent":"europe","continent":"Europe"},{"name":"BEL","iso3":null,"value":10896,"valuecolor":45840,"level":2,"color":"#68C85B","id":"bel","parent":"europe","continent":"Europe"},{"name":"BGR","iso3":null,"value":7534,"valuecolor":6280,"level":2,"color":"#249787","id":"bgr","parent":"europe","continent":"Europe"},{"name":"BIH","iso3":null,"value":3760,"valuecolor":4770,"level":2,"color":"#259488","id":"bih","parent":"europe","continent":"Europe"},{"name":"BLR","iso3":null,"value":9490,"valuecolor":5950,"level":2,"color":"#249787","id":"blr","parent":"europe","continent":"Europe"},{"name":"CHE","iso3":null,"value":7826,"valuecolor":71520,"level":2,"color":"#BBDC3B","id":"che","parent":"europe","continent":"Europe"},{"name":"CZE","iso3":null,"value":10520,"valuecolor":17890,"level":2,"color":"#22A784","id":"cze","parent":"europe","continent":"Europe"},{"name":"DEU","iso3":null,"value":81777,"valuecolor":43070,"level":2,"color":"#5FC460","id":"deu","parent":"europe","continent":"Europe"},{"name":"DNK","iso3":null,"value":5547,"valuecolor":59400,"level":2,"color":"#94D548","id":"dnk","parent":"europe","continent":"Europe"},{"name":"ESP","iso3":null,"value":46071,"valuecolor":31750,"level":2,"color":"#45B86F","id":"esp","parent":"europe","continent":"Europe"},{"name":"EST","iso3":null,"value":1340,"valuecolor":14460,"level":2,"color":"#22A385","id":"est","parent":"europe","continent":"Europe"},{"name":"FIN","iso3":null,"value":5364,"valuecolor":47570,"level":2,"color":"#6CCA58","id":"fin","parent":"europe","continent":"Europe"},{"name":"FRA","iso3":null,"value":64895,"valuecolor":42370,"level":2,"color":"#5FC460","id":"fra","parent":"europe","continent":"Europe"},{"name":"FRO","iso3":null,"value":49,"valuecolor":0,"level":2,"color":"#269089","id":"fro","parent":"europe","continent":"Europe"},{"name":"GBR","iso3":null,"value":62232,"valuecolor":38200,"level":2,"color":"#52BE67","id":"gbr","parent":"europe","continent":"Europe"},{"name":"GIB","iso3":null,"value":29,"valuecolor":0,"level":2,"color":"#269089","id":"gib","parent":"europe","continent":"Europe"},{"name":"GRC","iso3":null,"value":11316,"valuecolor":26950,"level":2,"color":"#37B277","id":"grc","parent":"europe","continent":"Europe"},{"name":"HRV","iso3":null,"value":4418,"valuecolor":13890,"level":2,"color":"#23A085","id":"hrv","parent":"europe","continent":"Europe"},{"name":"HUN","iso3":null,"value":10000,"valuecolor":12860,"level":2,"color":"#23A085","id":"hun","parent":"europe","continent":"Europe"},{"name":"IRL","iso3":null,"value":4475,"valuecolor":41820,"level":2,"color":"#5BC262","id":"irl","parent":"europe","continent":"Europe"},{"name":"ISL","iso3":null,"value":318,"valuecolor":32640,"level":2,"color":"#45B86F","id":"isl","parent":"europe","continent":"Europe"},{"name":"ITA","iso3":null,"value":60483,"valuecolor":35700,"level":2,"color":"#4EBC6A","id":"ita","parent":"europe","continent":"Europe"},{"name":"LIE","iso3":null,"value":36,"valuecolor":0,"level":2,"color":"#269089","id":"lie","parent":"europe","continent":"Europe"},{"name":"LTU","iso3":null,"value":3287,"valuecolor":11510,"level":2,"color":"#239E86","id":"ltu","parent":"europe","continent":"Europe"},{"name":"LUX","iso3":null,"value":507,"valuecolor":76980,"level":2,"color":"#D5E032","id":"lux","parent":"europe","continent":"Europe"},{"name":"LVA","iso3":null,"value":2239,"valuecolor":11640,"level":2,"color":"#239E86","id":"lva","parent":"europe","continent":"Europe"},{"name":"MCO","iso3":null,"value":35,"valuecolor":0,"level":2,"color":"#269089","id":"mco","parent":"europe","continent":"Europe"},{"name":"MDA","iso3":null,"value":3562,"valuecolor":1810,"level":2,"color":"#259288","id":"mda","parent":"europe","continent":"Europe"},{"name":"MKD","iso3":null,"value":2060,"valuecolor":4570,"level":2,"color":"#259488","id":"mkd","parent":"europe","continent":"Europe"},{"name":"MLT","iso3":null,"value":416,"valuecolor":19130,"level":2,"color":"#22A784","id":"mlt","parent":"europe","continent":"Europe"},{"name":"MNE","iso3":null,"value":632,"valuecolor":6740,"level":2,"color":"#249787","id":"mne","parent":"europe","continent":"Europe"},{"name":"NLD","iso3":null,"value":16616,"valuecolor":49030,"level":2,"color":"#71CC56","id":"nld","parent":"europe","continent":"Europe"},{"name":"NOR","iso3":null,"value":4889,"valuecolor":87350,"level":2,"color":"#FDE725","id":"nor","parent":"europe","continent":"Europe"},{"name":"POL","iso3":null,"value":38184,"valuecolor":12440,"level":2,"color":"#23A085","id":"pol","parent":"europe","continent":"Europe"},{"name":"PRT","iso3":null,"value":10638,"valuecolor":21870,"level":2,"color":"#2AAC7E","id":"prt","parent":"europe","continent":"Europe"},{"name":"RUS","iso3":null,"value":141750,"valuecolor":9900,"level":2,"color":"#249B86","id":"rus","parent":"europe","continent":"Europe"},{"name":"SMR","iso3":null,"value":32,"valuecolor":0,"level":2,"color":"#269089","id":"smr","parent":"europe","continent":"Europe"},{"name":"SRB","iso3":null,"value":7291,"valuecolor":5630,"level":2,"color":"#249787","id":"srb","parent":"europe","continent":"Europe"},{"name":"SVK","iso3":null,"value":5430,"valuecolor":16840,"level":2,"color":"#22A584","id":"svk","parent":"europe","continent":"Europe"},{"name":"SVN","iso3":null,"value":2049,"valuecolor":23900,"level":2,"color":"#2FAE7C","id":"svn","parent":"europe","continent":"Europe"},{"name":"SWE","iso3":null,"value":9378,"valuecolor":50100,"level":2,"color":"#71CC56","id":"swe","parent":"europe","continent":"Europe"},{"name":"UKR","iso3":null,"value":45871,"valuecolor":3000,"level":2,"color":"#259288","id":"ukr","parent":"europe","continent":"Europe"},{"name":"ABW","iso3":null,"value":108,"valuecolor":0,"level":2,"color":"#269089","id":"abw","parent":"north_america","continent":"North America"},{"name":"ATG","iso3":null,"value":88,"valuecolor":13280,"level":2,"color":"#23A085","id":"atg","parent":"north_america","continent":"North America"},{"name":"BHS","iso3":null,"value":343,"valuecolor":22240,"level":2,"color":"#2AAC7E","id":"bhs","parent":"north_america","continent":"North America"},{"name":"BLZ","iso3":null,"value":345,"valuecolor":3810,"level":2,"color":"#259488","id":"blz","parent":"north_america","continent":"North America"},{"name":"BMU","iso3":null,"value":65,"valuecolor":0,"level":2,"color":"#269089","id":"bmu","parent":"north_america","continent":"North America"},{"name":"BRB","iso3":null,"value":274,"valuecolor":0,"level":2,"color":"#269089","id":"brb","parent":"north_america","continent":"North America"},{"name":"CAN","iso3":null,"value":34126,"valuecolor":43250,"level":2,"color":"#5FC460","id":"can","parent":"north_america","continent":"North America"},{"name":"CRI","iso3":null,"value":4659,"valuecolor":6810,"level":2,"color":"#249787","id":"cri","parent":"north_america","continent":"North America"},{"name":"CUB","iso3":null,"value":11258,"valuecolor":0,"level":2,"color":"#269089","id":"cub","parent":"north_america","continent":"North America"},{"name":"CUW","iso3":null,"value":143,"valuecolor":0,"level":2,"color":"#269089","id":"cuw","parent":"north_america","continent":"North America"},{"name":"CYM","iso3":null,"value":56,"valuecolor":0,"level":2,"color":"#269089","id":"cym","parent":"north_america","continent":"North America"},{"name":"DMA","iso3":null,"value":68,"valuecolor":6740,"level":2,"color":"#249787","id":"dma","parent":"north_america","continent":"North America"},{"name":"DOM","iso3":null,"value":9927,"valuecolor":5030,"level":2,"color":"#259488","id":"dom","parent":"north_america","continent":"North America"},{"name":"GRD","iso3":null,"value":104,"valuecolor":6960,"level":2,"color":"#249787","id":"grd","parent":"north_america","continent":"North America"},{"name":"GRL","iso3":null,"value":57,"valuecolor":0,"level":2,"color":"#269089","id":"grl","parent":"north_america","continent":"North America"},{"name":"GTM","iso3":null,"value":14389,"valuecolor":2740,"level":2,"color":"#259288","id":"gtm","parent":"north_america","continent":"North America"},{"name":"HND","iso3":null,"value":7600,"valuecolor":1870,"level":2,"color":"#259288","id":"hnd","parent":"north_america","continent":"North America"},{"name":"HTI","iso3":null,"value":9993,"valuecolor":0,"level":2,"color":"#269089","id":"hti","parent":"north_america","continent":"North America"},{"name":"JAM","iso3":null,"value":2702,"valuecolor":4800,"level":2,"color":"#259488","id":"jam","parent":"north_america","continent":"North America"},{"name":"KNA","iso3":null,"value":52,"valuecolor":11830,"level":2,"color":"#239E86","id":"kna","parent":"north_america","continent":"North America"},{"name":"LCA","iso3":null,"value":174,"valuecolor":6560,"level":2,"color":"#249787","id":"lca","parent":"north_america","continent":"North America"},{"name":"MAF","iso3":null,"value":30,"valuecolor":0,"level":2,"color":"#269089","id":"maf","parent":"north_america","continent":"North America"},{"name":"MEX","iso3":null,"value":113423,"valuecolor":8930,"level":2,"color":"#249B86","id":"mex","parent":"north_america","continent":"North America"},{"name":"NIC","iso3":null,"value":5789,"valuecolor":1110,"level":2,"color":"#269089","id":"nic","parent":"north_america","continent":"North America"},{"name":"PAN","iso3":null,"value":3517,"valuecolor":6970,"level":2,"color":"#249787","id":"pan","parent":"north_america","continent":"North America"},{"name":"PRI","iso3":null,"value":3978,"valuecolor":15500,"level":2,"color":"#22A385","id":"pri","parent":"north_america","continent":"North America"},{"name":"SLV","iso3":null,"value":6193,"valuecolor":3380,"level":2,"color":"#259288","id":"slv","parent":"north_america","continent":"North America"},{"name":"SXM","iso3":null,"value":38,"valuecolor":0,"level":2,"color":"#269089","id":"sxm","parent":"north_america","continent":"North America"},{"name":"TCA","iso3":null,"value":38,"valuecolor":0,"level":2,"color":"#269089","id":"tca","parent":"north_america","continent":"North America"},{"name":"TTO","iso3":null,"value":1341,"valuecolor":15380,"level":2,"color":"#22A385","id":"tto","parent":"north_america","continent":"North America"},{"name":"USA","iso3":null,"value":309349,"valuecolor":47340,"level":2,"color":"#6CCA58","id":"usa","parent":"north_america","continent":"North America"},{"name":"VCT","iso3":null,"value":109,"valuecolor":6320,"level":2,"color":"#249787","id":"vct","parent":"north_america","continent":"North America"},{"name":"VIR","iso3":null,"value":110,"valuecolor":0,"level":2,"color":"#269089","id":"vir","parent":"north_america","continent":"North America"},{"name":"ASM","iso3":null,"value":68,"valuecolor":0,"level":2,"color":"#269089","id":"asm","parent":"oceania","continent":"Oceania"},{"name":"AUS","iso3":null,"value":22299,"valuecolor":46200,"level":2,"color":"#68C85B","id":"aus","parent":"oceania","continent":"Oceania"},{"name":"FJI","iso3":null,"value":860,"valuecolor":3630,"level":2,"color":"#259488","id":"fji","parent":"oceania","continent":"Oceania"},{"name":"FSM","iso3":null,"value":111,"valuecolor":2740,"level":2,"color":"#259288","id":"fsm","parent":"oceania","continent":"Oceania"},{"name":"GUM","iso3":null,"value":179,"valuecolor":0,"level":2,"color":"#269089","id":"gum","parent":"oceania","continent":"Oceania"},{"name":"KIR","iso3":null,"value":100,"valuecolor":2000,"level":2,"color":"#259288","id":"kir","parent":"oceania","continent":"Oceania"},{"name":"MHL","iso3":null,"value":54,"valuecolor":3640,"level":2,"color":"#259488","id":"mhl","parent":"oceania","continent":"Oceania"},{"name":"MNP","iso3":null,"value":61,"valuecolor":0,"level":2,"color":"#269089","id":"mnp","parent":"oceania","continent":"Oceania"},{"name":"NCL","iso3":null,"value":247,"valuecolor":0,"level":2,"color":"#269089","id":"ncl","parent":"oceania","continent":"Oceania"},{"name":"NZL","iso3":null,"value":4368,"valuecolor":0,"level":2,"color":"#269089","id":"nzl","parent":"oceania","continent":"Oceania"},{"name":"PLW","iso3":null,"value":20,"valuecolor":6560,"level":2,"color":"#249787","id":"plw","parent":"oceania","continent":"Oceania"},{"name":"PNG","iso3":null,"value":6858,"valuecolor":1300,"level":2,"color":"#269089","id":"png","parent":"oceania","continent":"Oceania"},{"name":"PYF","iso3":null,"value":271,"valuecolor":0,"level":2,"color":"#269089","id":"pyf","parent":"oceania","continent":"Oceania"},{"name":"SLB","iso3":null,"value":538,"valuecolor":1030,"level":2,"color":"#269089","id":"slb","parent":"oceania","continent":"Oceania"},{"name":"TON","iso3":null,"value":104,"valuecolor":3290,"level":2,"color":"#259288","id":"ton","parent":"oceania","continent":"Oceania"},{"name":"TUV","iso3":null,"value":10,"valuecolor":4760,"level":2,"color":"#259488","id":"tuv","parent":"oceania","continent":"Oceania"},{"name":"VUT","iso3":null,"value":240,"valuecolor":2640,"level":2,"color":"#259288","id":"vut","parent":"oceania","continent":"Oceania"},{"name":"WSM","iso3":null,"value":184,"valuecolor":2980,"level":2,"color":"#259288","id":"wsm","parent":"oceania","continent":"Oceania"},{"name":"ARG","iso3":null,"value":40412,"valuecolor":8620,"level":2,"color":"#249987","id":"arg","parent":"south_america","continent":"South America"},{"name":"BOL","iso3":null,"value":9929,"valuecolor":1810,"level":2,"color":"#259288","id":"bol","parent":"south_america","continent":"South America"},{"name":"BRA","iso3":null,"value":194946,"valuecolor":9390,"level":2,"color":"#249B86","id":"bra","parent":"south_america","continent":"South America"},{"name":"CHL","iso3":null,"value":17114,"valuecolor":10120,"level":2,"color":"#249B86","id":"chl","parent":"south_america","continent":"South America"},{"name":"COL","iso3":null,"value":46295,"valuecolor":5510,"level":2,"color":"#249787","id":"col","parent":"south_america","continent":"South America"},{"name":"ECU","iso3":null,"value":14465,"valuecolor":3850,"level":2,"color":"#259488","id":"ecu","parent":"south_america","continent":"South America"},{"name":"GUY","iso3":null,"value":755,"valuecolor":2870,"level":2,"color":"#259288","id":"guy","parent":"south_america","continent":"South America"},{"name":"PER","iso3":null,"value":29076,"valuecolor":4700,"level":2,"color":"#259488","id":"per","parent":"south_america","continent":"South America"},{"name":"PRY","iso3":null,"value":6454,"valuecolor":2720,"level":2,"color":"#259288","id":"pry","parent":"south_america","continent":"South America"},{"name":"SUR","iso3":null,"value":525,"valuecolor":0,"level":2,"color":"#269089","id":"sur","parent":"south_america","continent":"South America"},{"name":"URY","iso3":null,"value":3357,"valuecolor":10230,"level":2,"color":"#249B86","id":"ury","parent":"south_america","continent":"South America"},{"name":"VEN","iso3":null,"value":28834,"valuecolor":11590,"level":2,"color":"#239E86","id":"ven","parent":"south_america","continent":"South America"}],"type":"treemap","allowDrillToNode":true,"layoutAlgorithm":"squarified","name":"tmdata"}],"tooltip":{"pointFormat":"<b>{point.name}</b>:<br>\n             Pop: {point.value:,.0f}<br>\n             GNI: {point.valuecolor:,.0f}"}},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

### You can do anything ####
As uncle Bem said some day:

![SavePie](https://raw.githubusercontent.com/jbkunst/r-posts/master/032-presenting-highcharter/save%20pie.jpg)

You can use this pacakge for evil purposes so be good with the people who see 
your charts. So, I will not be happy if I see one chart like this:


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

<!--html_preserve--><div id="htmlwidget-3617" style="width:400px;height:400px;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-3617">{"x":{"hc_opts":{"title":{"text":"Nom! a delicious 3d pie!"},"credits":{"enabled":false},"exporting":{"enabled":false},"subtitle":{"text":"your eyes hurt?"},"chart":{"type":"pie","options3d":{"enabled":true,"alpha":70,"beta":0}},"plotOptions":{"pie":{"depth":70}},"series":[{"data":[{"name":"setosa","y":50},{"name":"versicolor","y":50},{"name":"virginica","y":50}]}]},"theme":{"chart":{"backgroundColor":null,"divBackgroundImage":"https://media.giphy.com/media/Yy26NRbpB9lDi/giphy.gif"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

### Other charts just for charting ####



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
  hc_credits(enabled = TRUE, text = "Source (plz click here!)",
             href = "https://www.youtube.com/watch?v=f_J8QU1m0Ng",
             style = list(fontSize = "12px")) %>% 
  hc_legend(enabled = FALSE) %>% 
  hc_tooltip(pointFormat = "{point.y}%")
```

<!--html_preserve--><div id="htmlwidget-578" style="width:100%;height:100%;" class="highchart"></div>
<script type="application/json" data-for="htmlwidget-578">{"x":{"hc_opts":{"title":{"text":"This is a bar graph describing my favorite pies\n           including a pie chart describing my favorite bars"},"credits":{"enabled":true,"text":"Source (plz click here!)","href":"https://www.youtube.com/watch?v=f_J8QU1m0Ng","style":{"fontSize":"12px"}},"exporting":{"enabled":false},"subtitle":{"text":"In percentage of tastiness and awesomeness"},"series":[{"data":[{"name":"Strawberry Rhubarb","y":85},{"name":"Pumpkin","y":64},{"name":"Lemon Meringue","y":75},{"name":"Blueberry","y":100},{"name":"Key Lime","y":57}],"name":"Pie","colorByPoint":true,"type":"column"},{"data":[{"name":"Mclaren's","y":30},{"name":"McGee's","y":28},{"name":"P & G","y":27},{"name":"White Horse Tavern","y":12},{"name":"King Cole Bar","y":3}],"type":"pie","name":"Bar","colorByPoint":true,"center":["35%","10%"],"size":100,"dataLabels":{"enabled":false}}],"yAxis":{"title":{"text":"percentage of tastiness"},"labels":{"format":"{value}%"},"max":100},"xAxis":{"categories":["Strawberry Rhubarb","Pumpkin","Lemon Meringue","Blueberry","Key Lime"]},"legend":{"enabled":false},"tooltip":{"pointFormat":"{point.y}%"}},"theme":null,"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to list(series.name)","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"debug":false,"fonts":[]},"evals":[]}</script><!--/html_preserve-->

Well, I hope you use, reuse and enjoy this package!

---
title: "readme.R"
author: "Joshua K"
date: "Thu Jan 14 00:24:48 2016"
---
