# Watching Forrest Gump through the Data
Joshua Kunst  



Packages and options


```r
library("dplyr")
library("rvest")
library("stringr")
library("purrr")
library("lubridate")
library("highcharter")

options(highcharter.theme = hc_theme_smpl())
```


> I'm not a smart man but I (*think to*) know what data is.
> <cite>-- Me</cite>




```r
urltl <- "http://www.timetoast.com/timelines/forrest-gump-timeline-of-events-and-major-figures"

df <- read_html(urltl) %>% 
  html_nodes(".list-timeline__list > li") %>% 
  map_df(function(x){
    # x <<- x
    data_frame(
      detail = x %>% html_node(".timeline-item__title") %>% html_text() %>% str_trim(),
      date = x %>% html_node("time") %>% html_attr("datetime"),
      date_fmt = x %>% html_node("time") %>% html_text(),
      imgurl =  x %>% html_node("img") %>% html_attr("src") %>% str_replace("//", "")  
      )
  })

df <- df %>% 
  mutate(date = ymd_hms(date),
         dt = datetime_to_timestamp(date),
         y = rep(4:1, length.out = nrow(df))) %>% 
  arrange(dt)
  
df <- df[-1, ]

glimpse(df)
```

```
## Observations: 19
## Variables: 6
## $ detail   <chr> "Estimated Birth Year", "Meets Elvis; Teaches Dance S...
## $ date     <dttm> 1944-01-01, 1956-01-01, 1962-10-01, 1963-07-11, 1963...
## $ date_fmt <chr> "Jan 1st, 1944", "Jan 1st, 1956", "Oct 1st, 1962", "J...
## $ imgurl   <chr> "s3.amazonaws.com/s3.timetoast.com/public/uploads/pho...
## $ dt       <dbl> -820540800000, -441849600000, -228873600000, -2044224...
## $ y        <int> 4, 3, 2, 1, 4, 3, 2, 1, 4, 3, 2, 1, 4, 3, 2, 1, 4, 3, 2
```

```r
hctl <- hchart(df, "point", hcaes(dt, y), name = "FG timeline") %>% 
  hc_xAxis(type = "datetime", title = list(text = ""),
           gridLineColor = "transparent") %>% 
  hc_yAxis(visible = FALSE) %>% 
  hc_size(height = 200)

hctl
```

<!--html_preserve--><div id="htmlwidget-f03282cacce745182155" style="width:100%;height:200px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-f03282cacce745182155">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"y"},"type":"linear","visible":false},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10},"series":[{"group":"group","data":[{"detail":"Estimated Birth Year","date":"1944-01-01T00:00:00Z","date_fmt":"Jan 1st, 1944","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496149/forrest-gump3.jpg?1334759244","dt":-820540800000,"y":4,"x":-820540800000},{"detail":"Meets Elvis; Teaches Dance Steps","date":"1956-01-01T00:00:00Z","date_fmt":"Jan 1st, 1956","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496169/elvis1.jpg?1334759500","dt":-441849600000,"y":3,"x":-441849600000},{"detail":"Plays for Legendary \"Bear\" Bryant Alabama Football Coach","date":"1962-10-01T00:00:00Z","date_fmt":"Oct 1st, 1962","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496238/bearbryant.jpg?1334760189","dt":-228873600000,"y":2,"x":-228873600000},{"detail":"Witnesses Racial Integration at University of Alabama with George Wallace Speaking","date":"1963-07-11T00:00:00Z","date_fmt":"Jul 11th, 1963","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496266/wallace1.jpg?1334760497","dt":-204422400000,"y":1,"x":-204422400000},{"detail":"Meets President Kennedy as All-American","date":"1963-11-01T00:00:00Z","date_fmt":"Nov 1st, 1963","imgurl":null,"dt":-194659200000,"y":4,"x":-194659200000},{"detail":"President Kennedy is Assassinated","date":"1963-11-22T00:00:00Z","date_fmt":"Nov 22nd, 1963","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496292/kennedy1.jpg?1334760881","dt":-192844800000,"y":3,"x":-192844800000},{"detail":"Forrest Fights in Vietnam","date":"1967-04-01T00:00:00Z","date_fmt":"Apr 1st, 1967","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496306/gumpvietnam.jpg?1334761309","dt":-86918400000,"y":2,"x":-86918400000},{"detail":"Jenny Joins the Counterculture; Becomes a Hippy","date":"1968-01-01T00:00:00Z","date_fmt":"Jan 1st, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496869/jennyforrestgumpistapeace.gif?1334766141","dt":-63158400000,"y":1,"x":-63158400000},{"detail":"Robert Kennedy is Assassinated","date":"1968-06-05T00:00:00Z","date_fmt":"Jun 5th, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496301/kennedy2.jpg?1334761144","dt":-49680000000,"y":4,"x":-49680000000},{"detail":"Receives Medal of Honor from LBJ","date":"1968-07-01T00:00:00Z","date_fmt":"Jul 1st, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496336/moh2.jpg?1334761778","dt":-47433600000,"y":3,"x":-47433600000},{"detail":"Speaks at Vietnam War Protest with Abby Hoffman; Meets Black Panthers","date":"1968-07-01T00:00:00Z","date_fmt":"Jul 1st, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496344/war_protest_washington-267x400.jpg?1334761912","dt":-47433600000,"y":2,"x":-47433600000},{"detail":"U.S. Moon Landing Shown on T.V.","date":"1969-07-20T00:00:00Z","date_fmt":"Jul 20th, 1969","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496468/moonlanding.jpg?1334763280","dt":-14256000000,"y":1,"x":-14256000000},{"detail":"Forrest Visits China with U.S. Ping Pong Team","date":"1971-04-10T00:00:00Z","date_fmt":"Apr 10th, 1971","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496484/gumpchina.jpg?1334763457","dt":40089600000,"y":4,"x":40089600000},{"detail":"Forrest Appears on the Dick Cavett Show with John Lennon","date":"1971-12-20T00:00:00Z","date_fmt":"Dec 20th, 1971","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496564/gumplennon.jpg?1334764151","dt":62035200000,"y":3,"x":62035200000},{"detail":"Meets President Nixon; Witnesses Watergate Break-In","date":"1972-06-17T00:00:00Z","date_fmt":"Jun 17th, 1972","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496601/gumpwatergate.jpg?1334764495","dt":77587200000,"y":2,"x":77587200000},{"detail":"Survives Hurricane Carmen; Bubba Gump Shrimp Co. Takes Off","date":"1974-09-08T00:00:00Z","date_fmt":"Sep 8th, 1974","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496652/carmen.gif?1334764817","dt":147830400000,"y":1,"x":147830400000},{"detail":"Lt. Dan Invests in Apple","date":"1975-09-23T00:00:00Z","date_fmt":"Sep 23rd, 1975","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496714/Apple-Forrest-Gump.jpg?1334765158","dt":180662400000,"y":4,"x":180662400000},{"detail":"Assassination Attempt Upon President Reagan","date":"1981-03-30T00:00:00Z","date_fmt":"Mar 30th, 1981","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496766/reagan-assassination-attempt.jpg?1334765499","dt":354758400000,"y":3,"x":354758400000},{"detail":"Jenny Diagnosed with HIV/AIDS; Passes Away","date":"1982-03-22T00:00:00Z","date_fmt":"Mar 22nd, 1982","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496925/jennyaids.jpg?1334766437","dt":385603200000,"y":2,"x":385603200000}],"type":"scatter","name":"FG timeline"}],"xAxis":{"type":"datetime","title":{"text":""},"gridLineColor":"transparent"}},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}},"spline":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}},"area":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}},"areaspline":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Tooltip



```r
tt <- tags$table(height = 100,
  tags$strong("{point.detail}"),
  tags$p("{point.date_fmt}"),
  tags$img(src = "http://{point.imgurl}",
           style="display: block;margin: 0 auto; height='80px'")
  )

cat(as.character(tt))
```

```
## <table height="100">
##   <strong>{point.detail}</strong>
##   <p>{point.date_fmt}</p>
##   <img src="http://{point.imgurl}" style="display: block;margin: 0 auto; height=&#39;80px&#39;"/>
## </table>
```

```r
hctl <- hctl %>% 
  hc_tooltip(pointFormat = as.character(tt),
             headerFormat = "",
             useHTML = TRUE)

hctl
```

<!--html_preserve--><div id="htmlwidget-e42689bfd4d56b496972" style="width:100%;height:200px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-e42689bfd4d56b496972">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"y"},"type":"linear","visible":false},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10,"pointFormat":"<table height=\"100\">\n  <strong>{point.detail}\u003c/strong>\n  <p>{point.date_fmt}\u003c/p>\n  <img src=\"http://{point.imgurl}\" style=\"display: block;margin: 0 auto; height=&#39;80px&#39;\"/>\n\u003c/table>","headerFormat":"","useHTML":true},"series":[{"group":"group","data":[{"detail":"Estimated Birth Year","date":"1944-01-01T00:00:00Z","date_fmt":"Jan 1st, 1944","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496149/forrest-gump3.jpg?1334759244","dt":-820540800000,"y":4,"x":-820540800000},{"detail":"Meets Elvis; Teaches Dance Steps","date":"1956-01-01T00:00:00Z","date_fmt":"Jan 1st, 1956","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496169/elvis1.jpg?1334759500","dt":-441849600000,"y":3,"x":-441849600000},{"detail":"Plays for Legendary \"Bear\" Bryant Alabama Football Coach","date":"1962-10-01T00:00:00Z","date_fmt":"Oct 1st, 1962","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496238/bearbryant.jpg?1334760189","dt":-228873600000,"y":2,"x":-228873600000},{"detail":"Witnesses Racial Integration at University of Alabama with George Wallace Speaking","date":"1963-07-11T00:00:00Z","date_fmt":"Jul 11th, 1963","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496266/wallace1.jpg?1334760497","dt":-204422400000,"y":1,"x":-204422400000},{"detail":"Meets President Kennedy as All-American","date":"1963-11-01T00:00:00Z","date_fmt":"Nov 1st, 1963","imgurl":null,"dt":-194659200000,"y":4,"x":-194659200000},{"detail":"President Kennedy is Assassinated","date":"1963-11-22T00:00:00Z","date_fmt":"Nov 22nd, 1963","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496292/kennedy1.jpg?1334760881","dt":-192844800000,"y":3,"x":-192844800000},{"detail":"Forrest Fights in Vietnam","date":"1967-04-01T00:00:00Z","date_fmt":"Apr 1st, 1967","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496306/gumpvietnam.jpg?1334761309","dt":-86918400000,"y":2,"x":-86918400000},{"detail":"Jenny Joins the Counterculture; Becomes a Hippy","date":"1968-01-01T00:00:00Z","date_fmt":"Jan 1st, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496869/jennyforrestgumpistapeace.gif?1334766141","dt":-63158400000,"y":1,"x":-63158400000},{"detail":"Robert Kennedy is Assassinated","date":"1968-06-05T00:00:00Z","date_fmt":"Jun 5th, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496301/kennedy2.jpg?1334761144","dt":-49680000000,"y":4,"x":-49680000000},{"detail":"Receives Medal of Honor from LBJ","date":"1968-07-01T00:00:00Z","date_fmt":"Jul 1st, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496336/moh2.jpg?1334761778","dt":-47433600000,"y":3,"x":-47433600000},{"detail":"Speaks at Vietnam War Protest with Abby Hoffman; Meets Black Panthers","date":"1968-07-01T00:00:00Z","date_fmt":"Jul 1st, 1968","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496344/war_protest_washington-267x400.jpg?1334761912","dt":-47433600000,"y":2,"x":-47433600000},{"detail":"U.S. Moon Landing Shown on T.V.","date":"1969-07-20T00:00:00Z","date_fmt":"Jul 20th, 1969","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496468/moonlanding.jpg?1334763280","dt":-14256000000,"y":1,"x":-14256000000},{"detail":"Forrest Visits China with U.S. Ping Pong Team","date":"1971-04-10T00:00:00Z","date_fmt":"Apr 10th, 1971","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496484/gumpchina.jpg?1334763457","dt":40089600000,"y":4,"x":40089600000},{"detail":"Forrest Appears on the Dick Cavett Show with John Lennon","date":"1971-12-20T00:00:00Z","date_fmt":"Dec 20th, 1971","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496564/gumplennon.jpg?1334764151","dt":62035200000,"y":3,"x":62035200000},{"detail":"Meets President Nixon; Witnesses Watergate Break-In","date":"1972-06-17T00:00:00Z","date_fmt":"Jun 17th, 1972","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496601/gumpwatergate.jpg?1334764495","dt":77587200000,"y":2,"x":77587200000},{"detail":"Survives Hurricane Carmen; Bubba Gump Shrimp Co. Takes Off","date":"1974-09-08T00:00:00Z","date_fmt":"Sep 8th, 1974","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496652/carmen.gif?1334764817","dt":147830400000,"y":1,"x":147830400000},{"detail":"Lt. Dan Invests in Apple","date":"1975-09-23T00:00:00Z","date_fmt":"Sep 23rd, 1975","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496714/Apple-Forrest-Gump.jpg?1334765158","dt":180662400000,"y":4,"x":180662400000},{"detail":"Assassination Attempt Upon President Reagan","date":"1981-03-30T00:00:00Z","date_fmt":"Mar 30th, 1981","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496766/reagan-assassination-attempt.jpg?1334765499","dt":354758400000,"y":3,"x":354758400000},{"detail":"Jenny Diagnosed with HIV/AIDS; Passes Away","date":"1982-03-22T00:00:00Z","date_fmt":"Mar 22nd, 1982","imgurl":"s3.amazonaws.com/s3.timetoast.com/public/uploads/photos/2496925/jennyaids.jpg?1334766437","dt":385603200000,"y":2,"x":385603200000}],"type":"scatter","name":"FG timeline"}],"xAxis":{"type":"datetime","title":{"text":""},"gridLineColor":"transparent"}},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}},"spline":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}},"area":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}},"areaspline":{"marker":{"enabled":false},"states":{"hover":{"lineWidthPlus":1}}}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


---
title: "readme.R"
author: "joshua.kunst"
date: "Tue Dec 06 16:21:30 2016"
---
