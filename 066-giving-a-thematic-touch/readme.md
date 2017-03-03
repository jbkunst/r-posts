# Giving a Thematic Touch to your Interactive Chart
Joshua Kunst  



## Preliminars

Usually (mainly at work) I made a chart and when I  present it nobody cares
about the style, if the chart comes from an excel spreadsheet, paint or
intercative chart, or colors, labels, font, or things I like to care.
That's sad for me but it's fine: the data/history behind and how you present
it is what matters. And surely I'm overreacting.

But hey! That's not implies you only must do always clean chart or tufte style plots.
Sometimes you can play with the topic of your chart and  give some _thematic touch_.

The first example that come to my mind is the _Iraq's bloody toll_ visualization:

![Iraq's bloody toll](http://cdn3.i-scmp.com/sites/default/files/styles/980w/public/2013/07/17/iraqdeaths.jpg)


So. We'll use some resources to try:

- Add some context of the topic before the viewer read something.
- Hopefully keep in the viewer's memory :) in a _gooood_ way.

Keeping the message intact, ie, don't abuse adding many element so the user 
don't lose the main point of the chart.

## The tools



```r
library(tidyverse) 
library(highcharter)
library(lubridate)
library(rvest)
library(janitor)
library(stringr)
library(jsonlite)
library(countrycode)
options(highcharter.debug = TRUE)
```

## Example I: Oil Spills

We can reuse the _bloody toll_ effect, using with _Oil Spills_ data. 

The [ourworldindata.org](https://ourworldindata.org/oil-spills/) website have 
a descriptive study Max Roser.

> Max Roser (2016) - 'Oil Spills'. Published online at OurWorldInData.org. 
> Retrieved from: https://ourworldindata.org/oil-spills/ [Online Resource]

They start with:

> Over the past 4 decades - the time for which we have data - oil spills
> decreased dramatically. Although oil spills also happen on land, 
> marine oil spills are considered more serious as the spilled oil is less containable

Let's load the data and make the basic chart.



```r
json <- read_lines("https://ourworldindata.org/wp-content/uploads/nvd3/nvd3_multiBarChart_Oil/multiBarChart_Oil.html")
json <- json[seq(
  which(str_detect(json, "var xxx")),
  first(which(str_detect(json, "\\}\\]\\;")))
)]

json <- fromJSON(str_replace_all(json, "var xxx = |;$", ""))
json <- transpose(json)

str(json)
```

```
## List of 2
##  $ :List of 2
##   ..$ values:'data.frame':	43 obs. of  2 variables:
##   .. ..$ x: num [1:43] 0.00 3.16e+10 6.31e+10 9.47e+10 1.26e+11 ...
##   .. ..$ y: int [1:43] 30 14 27 31 27 20 26 16 23 32 ...
##   ..$ key   : chr ">700 Tonnes"
##  $ :List of 2
##   ..$ values:'data.frame':	43 obs. of  2 variables:
##   .. ..$ x: num [1:43] 0.00 3.16e+10 6.31e+10 9.47e+10 1.26e+11 ...
##   .. ..$ y: int [1:43] 7 18 48 28 90 96 67 69 59 60 ...
##   ..$ key   : chr "7-700 Tonnes"
```

```r
dspills <- map_df(json, function(x) {
  df <- as.data.frame(x[["values"]])
  df$key <- x[["key"]]
  tbl_df(df)
  df
})

glimpse(dspills)
```

```
## Observations: 86
## Variables: 3
## $ x   <dbl> 0.00000e+00, 3.15569e+10, 6.31138e+10, 9.46707e+10, 1.2622...
## $ y   <int> 30, 14, 27, 31, 27, 20, 26, 16, 23, 32, 13, 7, 4, 13, 8, 8...
## $ key <chr> ">700 Tonnes", ">700 Tonnes", ">700 Tonnes", ">700 Tonnes"...
```

The data is ready. So we can make an staked area chart. I used _areaspline_
here to make a _liquid_ effect. 


```r
hcspills <- hchart(dspills, "areaspline", hcaes(x, y, group = "key")) %>% 
  hc_plotOptions(series = list(stacking = "normal")) %>% 
  hc_xAxis(type = "datetime") %>% 
  hc_title(text = "Number of Oil Spills Over the Past 4 Decades")
hcspills
```

<!--html_preserve--><div id="htmlwidget-5464dcef0265e6698d20" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-5464dcef0265e6698d20">{
  "x": {
    "hc_opts": {
      "title": {
        "text": "Number of Oil Spills Over the Past 4 Decades"
      },
      "yAxis": {
        "title": {
          "text": "y"
        },
        "type": "linear"
      },
      "credits": {
        "enabled": false
      },
      "exporting": {
        "enabled": false
      },
      "plotOptions": {
        "series": {
          "turboThreshold": 0,
          "showInLegend": true,
          "marker": {
            "enabled": true
          },
          "stacking": "normal"
        },
        "treemap": {
          "layoutAlgorithm": "squarified"
        },
        "scatter": {
          "marker": {
            "symbol": "circle"
          }
        }
      },
      "series": [
        {
          "name": ">700 Tonnes",
          "data": [
            {
              "x": 0,
              "y": 30,
              "key": ">700 Tonnes"
            },
            {
              "x": 31556900000,
              "y": 14,
              "key": ">700 Tonnes"
            },
            {
              "x": 63113800000,
              "y": 27,
              "key": ">700 Tonnes"
            },
            {
              "x": 94670700000,
              "y": 31,
              "key": ">700 Tonnes"
            },
            {
              "x": 126228000000,
              "y": 27,
              "key": ">700 Tonnes"
            },
            {
              "x": 157785000000,
              "y": 20,
              "key": ">700 Tonnes"
            },
            {
              "x": 189341000000,
              "y": 26,
              "key": ">700 Tonnes"
            },
            {
              "x": 220898000000,
              "y": 16,
              "key": ">700 Tonnes"
            },
            {
              "x": 252455000000,
              "y": 23,
              "key": ">700 Tonnes"
            },
            {
              "x": 284012000000,
              "y": 32,
              "key": ">700 Tonnes"
            },
            {
              "x": 315569000000,
              "y": 13,
              "key": ">700 Tonnes"
            },
            {
              "x": 347126000000,
              "y": 7,
              "key": ">700 Tonnes"
            },
            {
              "x": 378683000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 410240000000,
              "y": 13,
              "key": ">700 Tonnes"
            },
            {
              "x": 441797000000,
              "y": 8,
              "key": ">700 Tonnes"
            },
            {
              "x": 473354000000,
              "y": 8,
              "key": ">700 Tonnes"
            },
            {
              "x": 504910000000,
              "y": 7,
              "key": ">700 Tonnes"
            },
            {
              "x": 536467000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 568024000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 599581000000,
              "y": 13,
              "key": ">700 Tonnes"
            },
            {
              "x": 631138000000,
              "y": 14,
              "key": ">700 Tonnes"
            },
            {
              "x": 662695000000,
              "y": 7,
              "key": ">700 Tonnes"
            },
            {
              "x": 694252000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 725809000000,
              "y": 11,
              "key": ">700 Tonnes"
            },
            {
              "x": 757366000000,
              "y": 9,
              "key": ">700 Tonnes"
            },
            {
              "x": 788923000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 820479000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 852036000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 883593000000,
              "y": 5,
              "key": ">700 Tonnes"
            },
            {
              "x": 915150000000,
              "y": 6,
              "key": ">700 Tonnes"
            },
            {
              "x": 946707000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 978264000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 1009820000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 1041380000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 1072930000000,
              "y": 5,
              "key": ">700 Tonnes"
            },
            {
              "x": 1104490000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 1136050000000,
              "y": 5,
              "key": ">700 Tonnes"
            },
            {
              "x": 1167610000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 1199160000000,
              "y": 1,
              "key": ">700 Tonnes"
            },
            {
              "x": 1230720000000,
              "y": 1,
              "key": ">700 Tonnes"
            },
            {
              "x": 1262280000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 1293830000000,
              "y": 1,
              "key": ">700 Tonnes"
            },
            {
              "x": 1325390000000,
              "y": 0,
              "key": ">700 Tonnes"
            }
          ],
          "type": "areaspline"
        },
        {
          "name": "7-700 Tonnes",
          "data": [
            {
              "x": 0,
              "y": 7,
              "key": "7-700 Tonnes"
            },
            {
              "x": 31556900000,
              "y": 18,
              "key": "7-700 Tonnes"
            },
            {
              "x": 63113800000,
              "y": 48,
              "key": "7-700 Tonnes"
            },
            {
              "x": 94670700000,
              "y": 28,
              "key": "7-700 Tonnes"
            },
            {
              "x": 126228000000,
              "y": 90,
              "key": "7-700 Tonnes"
            },
            {
              "x": 157785000000,
              "y": 96,
              "key": "7-700 Tonnes"
            },
            {
              "x": 189341000000,
              "y": 67,
              "key": "7-700 Tonnes"
            },
            {
              "x": 220898000000,
              "y": 69,
              "key": "7-700 Tonnes"
            },
            {
              "x": 252455000000,
              "y": 59,
              "key": "7-700 Tonnes"
            },
            {
              "x": 284012000000,
              "y": 60,
              "key": "7-700 Tonnes"
            },
            {
              "x": 315569000000,
              "y": 52,
              "key": "7-700 Tonnes"
            },
            {
              "x": 347126000000,
              "y": 54,
              "key": "7-700 Tonnes"
            },
            {
              "x": 378683000000,
              "y": 46,
              "key": "7-700 Tonnes"
            },
            {
              "x": 410240000000,
              "y": 52,
              "key": "7-700 Tonnes"
            },
            {
              "x": 441797000000,
              "y": 26,
              "key": "7-700 Tonnes"
            },
            {
              "x": 473354000000,
              "y": 33,
              "key": "7-700 Tonnes"
            },
            {
              "x": 504910000000,
              "y": 27,
              "key": "7-700 Tonnes"
            },
            {
              "x": 536467000000,
              "y": 27,
              "key": "7-700 Tonnes"
            },
            {
              "x": 568024000000,
              "y": 11,
              "key": "7-700 Tonnes"
            },
            {
              "x": 599581000000,
              "y": 33,
              "key": "7-700 Tonnes"
            },
            {
              "x": 631138000000,
              "y": 51,
              "key": "7-700 Tonnes"
            },
            {
              "x": 662695000000,
              "y": 30,
              "key": "7-700 Tonnes"
            },
            {
              "x": 694252000000,
              "y": 31,
              "key": "7-700 Tonnes"
            },
            {
              "x": 725809000000,
              "y": 31,
              "key": "7-700 Tonnes"
            },
            {
              "x": 757366000000,
              "y": 26,
              "key": "7-700 Tonnes"
            },
            {
              "x": 788923000000,
              "y": 20,
              "key": "7-700 Tonnes"
            },
            {
              "x": 820479000000,
              "y": 20,
              "key": "7-700 Tonnes"
            },
            {
              "x": 852036000000,
              "y": 28,
              "key": "7-700 Tonnes"
            },
            {
              "x": 883593000000,
              "y": 25,
              "key": "7-700 Tonnes"
            },
            {
              "x": 915150000000,
              "y": 20,
              "key": "7-700 Tonnes"
            },
            {
              "x": 946707000000,
              "y": 21,
              "key": "7-700 Tonnes"
            },
            {
              "x": 978264000000,
              "y": 17,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1009820000000,
              "y": 12,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1041380000000,
              "y": 19,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1072930000000,
              "y": 17,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1104490000000,
              "y": 22,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1136050000000,
              "y": 13,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1167610000000,
              "y": 13,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1199160000000,
              "y": 8,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1230720000000,
              "y": 7,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1262280000000,
              "y": 4,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1293830000000,
              "y": 5,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1325390000000,
              "y": 7,
              "key": "7-700 Tonnes"
            }
          ],
          "type": "areaspline"
        }
      ],
      "xAxis": {
        "type": "datetime",
        "title": {
          "text": "x"
        }
      }
    },
    "theme": {
      "chart": {
        "backgroundColor": "transparent"
      }
    },
    "conf_opts": {
      "global": {
        "Date": null,
        "VMLRadialGradientURL": "http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png",
        "canvasToolsURL": "http =//code.highcharts.com/list(version)/modules/canvas-tools.js",
        "getTimezoneOffset": null,
        "timezoneOffset": 0,
        "useUTC": true
      },
      "lang": {
        "contextButtonTitle": "Chart context menu",
        "decimalPoint": ".",
        "downloadJPEG": "Download JPEG image",
        "downloadPDF": "Download PDF document",
        "downloadPNG": "Download PNG image",
        "downloadSVG": "Download SVG vector image",
        "drillUpText": "Back to {series.name}",
        "invalidDate": null,
        "loading": "Loading...",
        "months": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
        "noData": "No data to display",
        "numericSymbols": ["k", "M", "G", "T", "P", "E"],
        "printChart": "Print chart",
        "resetZoom": "Reset zoom",
        "resetZoomTitle": "Reset zoom level 1:1",
        "shortMonths": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        "thousandsSep": " ",
        "weekdays": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
      }
    },
    "type": "chart",
    "fonts": [],
    "debug": true
  },
  "evals": [],
  "jsHooks": []
}</script><!--/html_preserve-->

Yay, the spills are decreasing over time. So we can do:

- Add a _deep sea_ background.
- Reverse the `yAxis` to the give the _fall_ effect. 
- Add a dark colors to simulate the _oil_.
- Add the credits for give the _serious_ (? ;) ) touch.


```r
hcspills2 <- hcspills %>% 
  hc_colors(c("#000000", "#222222")) %>% 
  hc_title(
    align = "left",
    style = list(color = "black")
  ) %>% 
  hc_credits(
    enabled = TRUE,
    text = "Data from ITOPF.com",
    href = "http://www.itopf.com/knowledge-resources/data-statistics/statistics/"
  ) %>% 
  hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>% 
  hc_chart(
    divBackgroundImage = "http://www.drodd.com/images14/ocean-wallpaper30.jpg",
    backgroundColor = hex_to_rgba("white", 0.50)
  ) %>% 
  hc_tooltip(sort = TRUE, table = TRUE) %>% 
  hc_legend(align = "right", verticalAlign = "top",
            layout = "horizontal") %>% 
  hc_xAxis(opposite = TRUE, gridLineWidth = 0,
           title = list(text = "Time", style = list(color = "black")),
           lineColor = "black", tickColor = "black",
           labels = list(style = list(color = "black"))) %>% 
  hc_yAxis(reversed = TRUE, gridLineWidth = 0, lineWidth = 1, lineColor = "black",
           tickWidth = 1, tickLength = 10, tickColor = "black",
           title = list(text = "Oil Spills", style = list(color = "black")),
           labels = list(style = list(color = "black"))) %>% 
  hc_add_theme(hc_theme_elementary())

hcspills2
```

<!--html_preserve--><div id="htmlwidget-92b701c14c69318eec9c" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-92b701c14c69318eec9c">{
  "x": {
    "hc_opts": {
      "title": {
        "text": "Number of Oil Spills Over the Past 4 Decades",
        "align": "left",
        "style": {
          "color": "black"
        }
      },
      "yAxis": {
        "title": {
          "text": "Oil Spills",
          "style": {
            "color": "black"
          }
        },
        "type": "linear",
        "reversed": true,
        "gridLineWidth": 0,
        "lineWidth": 1,
        "lineColor": "black",
        "tickWidth": 1,
        "tickLength": 10,
        "tickColor": "black",
        "labels": {
          "style": {
            "color": "black"
          }
        }
      },
      "credits": {
        "enabled": true,
        "text": "Data from ITOPF.com",
        "href": "http://www.itopf.com/knowledge-resources/data-statistics/statistics/"
      },
      "exporting": {
        "enabled": false
      },
      "plotOptions": {
        "series": {
          "turboThreshold": 0,
          "showInLegend": true,
          "marker": {
            "enabled": false
          },
          "stacking": "normal"
        },
        "treemap": {
          "layoutAlgorithm": "squarified"
        },
        "scatter": {
          "marker": {
            "symbol": "circle"
          }
        }
      },
      "series": [
        {
          "name": ">700 Tonnes",
          "data": [
            {
              "x": 0,
              "y": 30,
              "key": ">700 Tonnes"
            },
            {
              "x": 31556900000,
              "y": 14,
              "key": ">700 Tonnes"
            },
            {
              "x": 63113800000,
              "y": 27,
              "key": ">700 Tonnes"
            },
            {
              "x": 94670700000,
              "y": 31,
              "key": ">700 Tonnes"
            },
            {
              "x": 126228000000,
              "y": 27,
              "key": ">700 Tonnes"
            },
            {
              "x": 157785000000,
              "y": 20,
              "key": ">700 Tonnes"
            },
            {
              "x": 189341000000,
              "y": 26,
              "key": ">700 Tonnes"
            },
            {
              "x": 220898000000,
              "y": 16,
              "key": ">700 Tonnes"
            },
            {
              "x": 252455000000,
              "y": 23,
              "key": ">700 Tonnes"
            },
            {
              "x": 284012000000,
              "y": 32,
              "key": ">700 Tonnes"
            },
            {
              "x": 315569000000,
              "y": 13,
              "key": ">700 Tonnes"
            },
            {
              "x": 347126000000,
              "y": 7,
              "key": ">700 Tonnes"
            },
            {
              "x": 378683000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 410240000000,
              "y": 13,
              "key": ">700 Tonnes"
            },
            {
              "x": 441797000000,
              "y": 8,
              "key": ">700 Tonnes"
            },
            {
              "x": 473354000000,
              "y": 8,
              "key": ">700 Tonnes"
            },
            {
              "x": 504910000000,
              "y": 7,
              "key": ">700 Tonnes"
            },
            {
              "x": 536467000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 568024000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 599581000000,
              "y": 13,
              "key": ">700 Tonnes"
            },
            {
              "x": 631138000000,
              "y": 14,
              "key": ">700 Tonnes"
            },
            {
              "x": 662695000000,
              "y": 7,
              "key": ">700 Tonnes"
            },
            {
              "x": 694252000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 725809000000,
              "y": 11,
              "key": ">700 Tonnes"
            },
            {
              "x": 757366000000,
              "y": 9,
              "key": ">700 Tonnes"
            },
            {
              "x": 788923000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 820479000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 852036000000,
              "y": 10,
              "key": ">700 Tonnes"
            },
            {
              "x": 883593000000,
              "y": 5,
              "key": ">700 Tonnes"
            },
            {
              "x": 915150000000,
              "y": 6,
              "key": ">700 Tonnes"
            },
            {
              "x": 946707000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 978264000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 1009820000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 1041380000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 1072930000000,
              "y": 5,
              "key": ">700 Tonnes"
            },
            {
              "x": 1104490000000,
              "y": 3,
              "key": ">700 Tonnes"
            },
            {
              "x": 1136050000000,
              "y": 5,
              "key": ">700 Tonnes"
            },
            {
              "x": 1167610000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 1199160000000,
              "y": 1,
              "key": ">700 Tonnes"
            },
            {
              "x": 1230720000000,
              "y": 1,
              "key": ">700 Tonnes"
            },
            {
              "x": 1262280000000,
              "y": 4,
              "key": ">700 Tonnes"
            },
            {
              "x": 1293830000000,
              "y": 1,
              "key": ">700 Tonnes"
            },
            {
              "x": 1325390000000,
              "y": 0,
              "key": ">700 Tonnes"
            }
          ],
          "type": "areaspline"
        },
        {
          "name": "7-700 Tonnes",
          "data": [
            {
              "x": 0,
              "y": 7,
              "key": "7-700 Tonnes"
            },
            {
              "x": 31556900000,
              "y": 18,
              "key": "7-700 Tonnes"
            },
            {
              "x": 63113800000,
              "y": 48,
              "key": "7-700 Tonnes"
            },
            {
              "x": 94670700000,
              "y": 28,
              "key": "7-700 Tonnes"
            },
            {
              "x": 126228000000,
              "y": 90,
              "key": "7-700 Tonnes"
            },
            {
              "x": 157785000000,
              "y": 96,
              "key": "7-700 Tonnes"
            },
            {
              "x": 189341000000,
              "y": 67,
              "key": "7-700 Tonnes"
            },
            {
              "x": 220898000000,
              "y": 69,
              "key": "7-700 Tonnes"
            },
            {
              "x": 252455000000,
              "y": 59,
              "key": "7-700 Tonnes"
            },
            {
              "x": 284012000000,
              "y": 60,
              "key": "7-700 Tonnes"
            },
            {
              "x": 315569000000,
              "y": 52,
              "key": "7-700 Tonnes"
            },
            {
              "x": 347126000000,
              "y": 54,
              "key": "7-700 Tonnes"
            },
            {
              "x": 378683000000,
              "y": 46,
              "key": "7-700 Tonnes"
            },
            {
              "x": 410240000000,
              "y": 52,
              "key": "7-700 Tonnes"
            },
            {
              "x": 441797000000,
              "y": 26,
              "key": "7-700 Tonnes"
            },
            {
              "x": 473354000000,
              "y": 33,
              "key": "7-700 Tonnes"
            },
            {
              "x": 504910000000,
              "y": 27,
              "key": "7-700 Tonnes"
            },
            {
              "x": 536467000000,
              "y": 27,
              "key": "7-700 Tonnes"
            },
            {
              "x": 568024000000,
              "y": 11,
              "key": "7-700 Tonnes"
            },
            {
              "x": 599581000000,
              "y": 33,
              "key": "7-700 Tonnes"
            },
            {
              "x": 631138000000,
              "y": 51,
              "key": "7-700 Tonnes"
            },
            {
              "x": 662695000000,
              "y": 30,
              "key": "7-700 Tonnes"
            },
            {
              "x": 694252000000,
              "y": 31,
              "key": "7-700 Tonnes"
            },
            {
              "x": 725809000000,
              "y": 31,
              "key": "7-700 Tonnes"
            },
            {
              "x": 757366000000,
              "y": 26,
              "key": "7-700 Tonnes"
            },
            {
              "x": 788923000000,
              "y": 20,
              "key": "7-700 Tonnes"
            },
            {
              "x": 820479000000,
              "y": 20,
              "key": "7-700 Tonnes"
            },
            {
              "x": 852036000000,
              "y": 28,
              "key": "7-700 Tonnes"
            },
            {
              "x": 883593000000,
              "y": 25,
              "key": "7-700 Tonnes"
            },
            {
              "x": 915150000000,
              "y": 20,
              "key": "7-700 Tonnes"
            },
            {
              "x": 946707000000,
              "y": 21,
              "key": "7-700 Tonnes"
            },
            {
              "x": 978264000000,
              "y": 17,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1009820000000,
              "y": 12,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1041380000000,
              "y": 19,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1072930000000,
              "y": 17,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1104490000000,
              "y": 22,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1136050000000,
              "y": 13,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1167610000000,
              "y": 13,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1199160000000,
              "y": 8,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1230720000000,
              "y": 7,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1262280000000,
              "y": 4,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1293830000000,
              "y": 5,
              "key": "7-700 Tonnes"
            },
            {
              "x": 1325390000000,
              "y": 7,
              "key": "7-700 Tonnes"
            }
          ],
          "type": "areaspline"
        }
      ],
      "xAxis": {
        "type": "datetime",
        "title": {
          "text": "Time",
          "style": {
            "color": "black"
          }
        },
        "opposite": true,
        "gridLineWidth": 0,
        "lineColor": "black",
        "tickColor": "black",
        "labels": {
          "style": {
            "color": "black"
          }
        }
      },
      "colors": ["#000000", "#222222"],
      "chart": {
        "divBackgroundImage": "http://www.drodd.com/images14/ocean-wallpaper30.jpg",
        "backgroundColor": "rgba(255,255,255,0.5)"
      },
      "tooltip": {
        "shared": true,
        "formatter": "function(tooltip){\n          function isArray(obj) {\n          return Object.prototype.toString.call(obj) === '[object Array]';\n          }\n          \n          function splat(obj) {\n          return isArray(obj) ? obj : [obj];\n          }\n          \n          var items = this.points || splat(this), series = items[0].series, s;\n          \n          // sort the values\n          items.sort(function(a, b){\n          return ((a.y < b.y) ? -1 : ((a.y > b.y) ? 1 : 0));\n          });\n          items.reverse();\n          \n          return tooltip.defaultFormatter.call(this, tooltip);\n        }",
        "useHTML": true,
        "headerFormat": "<small>{point.key}\u003c/small><table>",
        "pointFormat": "<tr><td style=\"color: {series.color}\">{series.name}: \u003c/td><td style=\"text-align: right\"><b>{point.y}\u003c/b>\u003c/td>\u003c/tr>",
        "footerFormat": "\u003c/table>"
      },
      "legend": {
        "align": "right",
        "verticalAlign": "top",
        "layout": "horizontal"
      }
    },
    "theme": {
      "colors": [
        "#41B5E9",
        "#FA8832",
        "#34393C",
        "#E46151"
      ],
      "chart": {
        "style": {
          "color": "#333",
          "fontFamily": "Open Sans"
        }
      },
      "title": {
        "style": {
          "fontFamily": "Raleway",
          "fontWeight": "100"
        }
      },
      "subtitle": {
        "style": {
          "fontFamily": "Raleway",
          "fontWeight": "100"
        }
      },
      "legend": {
        "align": "right",
        "verticalAlign": "bottom"
      },
      "xAxis": {
        "gridLineWidth": 1,
        "gridLineColor": "#F3F3F3",
        "lineColor": "#F3F3F3",
        "minorGridLineColor": "#F3F3F3",
        "tickColor": "#F3F3F3",
        "tickWidth": 1
      },
      "yAxis": {
        "gridLineColor": "#F3F3F3",
        "lineColor": "#F3F3F3",
        "minorGridLineColor": "#F3F3F3",
        "tickColor": "#F3F3F3",
        "tickWidth": 1
      }
    },
    "conf_opts": {
      "global": {
        "Date": null,
        "VMLRadialGradientURL": "http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png",
        "canvasToolsURL": "http =//code.highcharts.com/list(version)/modules/canvas-tools.js",
        "getTimezoneOffset": null,
        "timezoneOffset": 0,
        "useUTC": true
      },
      "lang": {
        "contextButtonTitle": "Chart context menu",
        "decimalPoint": ".",
        "downloadJPEG": "Download JPEG image",
        "downloadPDF": "Download PDF document",
        "downloadPNG": "Download PNG image",
        "downloadSVG": "Download SVG vector image",
        "drillUpText": "Back to {series.name}",
        "invalidDate": null,
        "loading": "Loading...",
        "months": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
        "noData": "No data to display",
        "numericSymbols": ["k", "M", "G", "T", "P", "E"],
        "printChart": "Print chart",
        "resetZoom": "Reset zoom",
        "resetZoomTitle": "Reset zoom level 1:1",
        "shortMonths": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        "thousandsSep": " ",
        "weekdays": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
      }
    },
    "type": "chart",
    "fonts": ["Open+Sans", "Raleway"],
    "debug": true
  },
  "evals": ["hc_opts.tooltip.formatter"],
  "jsHooks": []
}</script><!--/html_preserve-->


# Example II: Winter Olympic Games

Here we will take the data and chart the participating nations over the 
years.



```r
tables <- read_html("https://en.wikipedia.org/wiki/Winter_Olympic_Games") %>% 
  html_table(fill = TRUE)

dgames <- tables[[5]]
dgames <- clean_names(dgames)
dgames <- dmap_if(dgames, is.character, str_trim)

dgames <- dgames[-1, ]
dgames <- filter(dgames, !games %in% c("1940", "1944"))
dgames <- filter(dgames, !year %in% seq(2018, by = 4, length.out = 4))
```

Not sure how re-read data to get the right column types. So a dirty trick. 


```r
tf <- tempfile(fileext = ".csv")
write_csv(dgames, tf)
dgames <- read_csv(tf)

dgames <- mutate(dgames,
                 nations = str_extract(nations, "\\d+"),
                 nations = as.numeric(nations))

glimpse(dgames)
```

```
## Observations: 22
## Variables: 14
## $ games         <chr> "I", "II", "III", "IV", "V", "VI", "VII", "VIII"...
## $ year          <int> 1924, 1928, 1932, 1936, 1948, 1952, 1956, 1960, ...
## $ host          <chr> "Chamonix, France", "St. Moritz, Switzerland", "...
## $ opened_by     <chr> "Undersecretary Gaston Vidal", "President Edmund...
## $ dates         <chr> "25 January <U+0096> 5 February", "11<U+0096>19 February", "4<U+0096>...
## $ nations       <dbl> 16, 25, 17, 28, 28, 30, 32, 30, 36, 37, 35, 37, ...
## $ competitors   <int> 258, 464, 252, 646, 669, 694, 821, 665, 1091, 11...
## $ competitors_2 <int> 247, 438, 231, 566, 592, 585, 687, 521, 892, 947...
## $ competitors_3 <int> 11, 26, 21, 80, 77, 109, 134, 144, 199, 211, 205...
## $ sports        <int> 6, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, ...
## $ disci_plines  <int> 9, 8, 7, 8, 9, 8, 8, 8, 10, 10, 10, 10, 10, 10, ...
## $ events        <int> 16, 14, 14, 17, 22, 22, 24, 27, 34, 35, 35, 37, ...
## $ top_nation    <chr> "Norway (NOR)", "Norway (NOR)", "United States (...
## $ ref           <chr> "[2]", "[3]", "[4]", "[5]", "[6]", "[7]", "[8]",...
```

Let's see the first chart:


```r
hcgames <- hchart(dgames, "areaspline", hcaes(year, nations, name = host), name = "Nations") %>% 
  hc_title(text = "Number of Participating Nations in every Winter Olympic Games") %>%
  hc_xAxis(title = list(text = "Time")) %>% 
  hc_yAxis(title = list(text = "Nations"))
  
hcgames
```

<!--html_preserve--><div id="htmlwidget-ba23a23ecc523d35fcd1" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-ba23a23ecc523d35fcd1">{
  "x": {
    "hc_opts": {
      "title": {
        "text": "Number of Participating Nations in every Winter Olympic Games"
      },
      "yAxis": {
        "title": {
          "text": "Nations"
        },
        "type": "linear"
      },
      "credits": {
        "enabled": false
      },
      "exporting": {
        "enabled": false
      },
      "plotOptions": {
        "series": {
          "turboThreshold": 0,
          "showInLegend": false,
          "marker": {
            "enabled": true
          }
        },
        "treemap": {
          "layoutAlgorithm": "squarified"
        },
        "scatter": {
          "marker": {
            "symbol": "circle"
          }
        }
      },
      "series": [
        {
          "group": "group",
          "data": [
            {
              "games": "I",
              "year": 1924,
              "host": "Chamonix, France",
              "opened_by": "Undersecretary Gaston Vidal",
              "dates": "25 January  5 February",
              "nations": 16,
              "competitors": 258,
              "competitors_2": 247,
              "competitors_3": 11,
              "sports": 6,
              "disci_plines": 9,
              "events": 16,
              "top_nation": "Norway (NOR)",
              "ref": "[2]",
              "x": 1924,
              "y": 16,
              "name": "Chamonix, France"
            },
            {
              "games": "II",
              "year": 1928,
              "host": "St. Moritz, Switzerland",
              "opened_by": "President Edmund Schulthess",
              "dates": "1119 February",
              "nations": 25,
              "competitors": 464,
              "competitors_2": 438,
              "competitors_3": 26,
              "sports": 4,
              "disci_plines": 8,
              "events": 14,
              "top_nation": "Norway (NOR)",
              "ref": "[3]",
              "x": 1928,
              "y": 25,
              "name": "St. Moritz, Switzerland"
            },
            {
              "games": "III",
              "year": 1932,
              "host": "Lake Placid, United States",
              "opened_by": "Governor Franklin D. Roosevelt",
              "dates": "415 February",
              "nations": 17,
              "competitors": 252,
              "competitors_2": 231,
              "competitors_3": 21,
              "sports": 4,
              "disci_plines": 7,
              "events": 14,
              "top_nation": "United States (USA)",
              "ref": "[4]",
              "x": 1932,
              "y": 17,
              "name": "Lake Placid, United States"
            },
            {
              "games": "IV",
              "year": 1936,
              "host": "Garmisch-Partenkirchen, Germany",
              "opened_by": "Chancellor Adolf Hitler",
              "dates": "616 February",
              "nations": 28,
              "competitors": 646,
              "competitors_2": 566,
              "competitors_3": 80,
              "sports": 4,
              "disci_plines": 8,
              "events": 17,
              "top_nation": "Norway (NOR)",
              "ref": "[5]",
              "x": 1936,
              "y": 28,
              "name": "Garmisch-Partenkirchen, Germany"
            },
            {
              "games": "V",
              "year": 1948,
              "host": "St. Moritz, Switzerland",
              "opened_by": "President Enrico Celio",
              "dates": "30 January  8 February",
              "nations": 28,
              "competitors": 669,
              "competitors_2": 592,
              "competitors_3": 77,
              "sports": 4,
              "disci_plines": 9,
              "events": 22,
              "top_nation": "Norway (NOR) Sweden (SWE)",
              "ref": "[6]",
              "x": 1948,
              "y": 28,
              "name": "St. Moritz, Switzerland"
            },
            {
              "games": "VI",
              "year": 1952,
              "host": "Oslo, Norway",
              "opened_by": "Princess Ragnhild",
              "dates": "1425 February",
              "nations": 30,
              "competitors": 694,
              "competitors_2": 585,
              "competitors_3": 109,
              "sports": 4,
              "disci_plines": 8,
              "events": 22,
              "top_nation": "Norway (NOR)",
              "ref": "[7]",
              "x": 1952,
              "y": 30,
              "name": "Oslo, Norway"
            },
            {
              "games": "VII",
              "year": 1956,
              "host": "Cortina d'Ampezzo, Italy",
              "opened_by": "President Giovanni Gronchi",
              "dates": "26 January  5 February",
              "nations": 32,
              "competitors": 821,
              "competitors_2": 687,
              "competitors_3": 134,
              "sports": 4,
              "disci_plines": 8,
              "events": 24,
              "top_nation": "Soviet Union (URS)",
              "ref": "[8]",
              "x": 1956,
              "y": 32,
              "name": "Cortina d'Ampezzo, Italy"
            },
            {
              "games": "VIII",
              "year": 1960,
              "host": "Squaw Valley, United States",
              "opened_by": "Vice President Richard Nixon",
              "dates": "1828 February",
              "nations": 30,
              "competitors": 665,
              "competitors_2": 521,
              "competitors_3": 144,
              "sports": 4,
              "disci_plines": 8,
              "events": 27,
              "top_nation": "Soviet Union (URS)",
              "ref": "[9]",
              "x": 1960,
              "y": 30,
              "name": "Squaw Valley, United States"
            },
            {
              "games": "IX",
              "year": 1964,
              "host": "Innsbruck, Austria",
              "opened_by": "President Adolf Schärf",
              "dates": "29 January  9 February",
              "nations": 36,
              "competitors": 1091,
              "competitors_2": 892,
              "competitors_3": 199,
              "sports": 6,
              "disci_plines": 10,
              "events": 34,
              "top_nation": "Soviet Union (URS)",
              "ref": "[10]",
              "x": 1964,
              "y": 36,
              "name": "Innsbruck, Austria"
            },
            {
              "games": "X",
              "year": 1968,
              "host": "Grenoble, France",
              "opened_by": "President Charles de Gaulle",
              "dates": "618 February",
              "nations": 37,
              "competitors": 1158,
              "competitors_2": 947,
              "competitors_3": 211,
              "sports": 6,
              "disci_plines": 10,
              "events": 35,
              "top_nation": "Norway (NOR)",
              "ref": "[11]",
              "x": 1968,
              "y": 37,
              "name": "Grenoble, France"
            },
            {
              "games": "XI",
              "year": 1972,
              "host": "Sapporo, Japan",
              "opened_by": "Emperor Hirohito",
              "dates": "313 February",
              "nations": 35,
              "competitors": 1006,
              "competitors_2": 801,
              "competitors_3": 205,
              "sports": 6,
              "disci_plines": 10,
              "events": 35,
              "top_nation": "Soviet Union (URS)",
              "ref": "[12]",
              "x": 1972,
              "y": 35,
              "name": "Sapporo, Japan"
            },
            {
              "games": "XII",
              "year": 1976,
              "host": "Innsbruck, Austria",
              "opened_by": "President Rudolf Kirchschläger",
              "dates": "415 February",
              "nations": 37,
              "competitors": 1123,
              "competitors_2": 892,
              "competitors_3": 231,
              "sports": 6,
              "disci_plines": 10,
              "events": 37,
              "top_nation": "Soviet Union (URS)",
              "ref": "[13]",
              "x": 1976,
              "y": 37,
              "name": "Innsbruck, Austria"
            },
            {
              "games": "XIII",
              "year": 1980,
              "host": "Lake Placid, United States",
              "opened_by": "Vice President Walter Mondale",
              "dates": "1324 February",
              "nations": 37,
              "competitors": 1072,
              "competitors_2": 840,
              "competitors_3": 232,
              "sports": 6,
              "disci_plines": 10,
              "events": 38,
              "top_nation": "Soviet Union (URS)",
              "ref": "[14]",
              "x": 1980,
              "y": 37,
              "name": "Lake Placid, United States"
            },
            {
              "games": "XIV",
              "year": 1984,
              "host": "Sarajevo, Yugoslavia",
              "opened_by": "President Mika piljak",
              "dates": "819 February",
              "nations": 49,
              "competitors": 1272,
              "competitors_2": 998,
              "competitors_3": 274,
              "sports": 6,
              "disci_plines": 10,
              "events": 39,
              "top_nation": "East Germany (GDR)",
              "ref": "[15]",
              "x": 1984,
              "y": 49,
              "name": "Sarajevo, Yugoslavia"
            },
            {
              "games": "XV",
              "year": 1988,
              "host": "Calgary, Canada",
              "opened_by": "Governor General Jeanne Sauvé",
              "dates": "1328 February",
              "nations": 57,
              "competitors": 1423,
              "competitors_2": 1122,
              "competitors_3": 301,
              "sports": 6,
              "disci_plines": 10,
              "events": 46,
              "top_nation": "Soviet Union (URS)",
              "ref": "[16]",
              "x": 1988,
              "y": 57,
              "name": "Calgary, Canada"
            },
            {
              "games": "XVI",
              "year": 1992,
              "host": "Albertville, France",
              "opened_by": "President François Mitterrand",
              "dates": "823 February",
              "nations": 64,
              "competitors": 1801,
              "competitors_2": 1313,
              "competitors_3": 488,
              "sports": 6,
              "disci_plines": 12,
              "events": 57,
              "top_nation": "Germany (GER)",
              "ref": "[17]",
              "x": 1992,
              "y": 64,
              "name": "Albertville, France"
            },
            {
              "games": "XVII",
              "year": 1994,
              "host": "Lillehammer, Norway",
              "opened_by": "King Harald V",
              "dates": "1227 February",
              "nations": 67,
              "competitors": 1737,
              "competitors_2": 1215,
              "competitors_3": 522,
              "sports": 6,
              "disci_plines": 12,
              "events": 61,
              "top_nation": "Russia (RUS)",
              "ref": "[18]",
              "x": 1994,
              "y": 67,
              "name": "Lillehammer, Norway"
            },
            {
              "games": "XVIII",
              "year": 1998,
              "host": "Nagano, Japan",
              "opened_by": "Emperor Akihito",
              "dates": "722 February",
              "nations": 72,
              "competitors": 2176,
              "competitors_2": 1389,
              "competitors_3": 787,
              "sports": 7,
              "disci_plines": 14,
              "events": 68,
              "top_nation": "Germany (GER)",
              "ref": "[19]",
              "x": 1998,
              "y": 72,
              "name": "Nagano, Japan"
            },
            {
              "games": "XIX",
              "year": 2002,
              "host": "Salt Lake City, United States",
              "opened_by": "President George W. Bush",
              "dates": "824 February",
              "nations": 78,
              "competitors": 2399,
              "competitors_2": 1513,
              "competitors_3": 886,
              "sports": 7,
              "disci_plines": 15,
              "events": 78,
              "top_nation": "Norway (NOR)",
              "ref": "[20]",
              "x": 2002,
              "y": 78,
              "name": "Salt Lake City, United States"
            },
            {
              "games": "XX",
              "year": 2006,
              "host": "Turin, Italy",
              "opened_by": "President Carlo Azeglio Ciampi",
              "dates": "1026 February",
              "nations": 80,
              "competitors": 2508,
              "competitors_2": 1548,
              "competitors_3": 960,
              "sports": 7,
              "disci_plines": 15,
              "events": 84,
              "top_nation": "Germany (GER)",
              "ref": "[21]",
              "x": 2006,
              "y": 80,
              "name": "Turin, Italy"
            },
            {
              "games": "XXI",
              "year": 2010,
              "host": "Vancouver, Canada",
              "opened_by": "Governor General Michaëlle Jean",
              "dates": "1228 February",
              "nations": 82,
              "competitors": 2566,
              "competitors_2": 1522,
              "competitors_3": 1044,
              "sports": 7,
              "disci_plines": 15,
              "events": 86,
              "top_nation": "Canada (CAN)",
              "ref": "[22]",
              "x": 2010,
              "y": 82,
              "name": "Vancouver, Canada"
            },
            {
              "games": "XXII",
              "year": 2014,
              "host": "Sochi, Russia",
              "opened_by": "President Vladimir Putin",
              "dates": "723 February",
              "nations": 88,
              "competitors": 2873,
              "competitors_2": 1714,
              "competitors_3": 1159,
              "sports": 7,
              "disci_plines": 15,
              "events": 98,
              "top_nation": "Russia (RUS)",
              "ref": "[23]",
              "x": 2014,
              "y": 88,
              "name": "Sochi, Russia"
            }
          ],
          "type": "areaspline",
          "name": "Nations"
        }
      ],
      "xAxis": {
        "type": "linear",
        "title": {
          "text": "Time"
        }
      }
    },
    "theme": {
      "chart": {
        "backgroundColor": "transparent"
      }
    },
    "conf_opts": {
      "global": {
        "Date": null,
        "VMLRadialGradientURL": "http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png",
        "canvasToolsURL": "http =//code.highcharts.com/list(version)/modules/canvas-tools.js",
        "getTimezoneOffset": null,
        "timezoneOffset": 0,
        "useUTC": true
      },
      "lang": {
        "contextButtonTitle": "Chart context menu",
        "decimalPoint": ".",
        "downloadJPEG": "Download JPEG image",
        "downloadPDF": "Download PDF document",
        "downloadPNG": "Download PNG image",
        "downloadSVG": "Download SVG vector image",
        "drillUpText": "Back to {series.name}",
        "invalidDate": null,
        "loading": "Loading...",
        "months": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
        "noData": "No data to display",
        "numericSymbols": ["k", "M", "G", "T", "P", "E"],
        "printChart": "Print chart",
        "resetZoom": "Reset zoom",
        "resetZoomTitle": "Reset zoom level 1:1",
        "shortMonths": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        "thousandsSep": " ",
        "weekdays": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
      }
    },
    "type": "chart",
    "fonts": [],
    "debug": true
  },
  "evals": [],
  "jsHooks": []
}</script><!--/html_preserve-->

With that increase of nations in 1980 we can:

- Use a white color to simulate a big snowed mountain.
- Put a relevant background.
- Put some flags for each host.
- And work on the tooltip to show more information.



```r
urlico <- "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/%s.png)"

dgames <- dgames %>% 
  mutate(country = str_extract(host, ", .*$"),
         country = str_replace(country, ", ", ""),
         country = str_trim(country)) %>% 
  mutate(countrycode = countrycode(country, origin = "country.name", destination = "iso2c")) %>% 
  mutate(marker = sprintf(urlico, countrycode),
         marker = map(marker, function(x) list(symbol = x)),
         flagicon = sprintf(urlico, countrycode),
         flagicon = str_replace_all(flagicon, "url\\(|\\)", "")) %>% 
  rename(men = competitors_2, women = competitors_3)

glimpse(dgames)
```

```
## Observations: 22
## Variables: 18
## $ games        <chr> "I", "II", "III", "IV", "V", "VI", "VII", "VIII",...
## $ year         <int> 1924, 1928, 1932, 1936, 1948, 1952, 1956, 1960, 1...
## $ host         <chr> "Chamonix, France", "St. Moritz, Switzerland", "L...
## $ opened_by    <chr> "Undersecretary Gaston Vidal", "President Edmund ...
## $ dates        <chr> "25 January <U+0096> 5 February", "11<U+0096>19 February", "4<U+0096>1...
## $ nations      <dbl> 16, 25, 17, 28, 28, 30, 32, 30, 36, 37, 35, 37, 3...
## $ competitors  <int> 258, 464, 252, 646, 669, 694, 821, 665, 1091, 115...
## $ men          <int> 247, 438, 231, 566, 592, 585, 687, 521, 892, 947,...
## $ women        <int> 11, 26, 21, 80, 77, 109, 134, 144, 199, 211, 205,...
## $ sports       <int> 6, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6...
## $ disci_plines <int> 9, 8, 7, 8, 9, 8, 8, 8, 10, 10, 10, 10, 10, 10, 1...
## $ events       <int> 16, 14, 14, 17, 22, 22, 24, 27, 34, 35, 35, 37, 3...
## $ top_nation   <chr> "Norway (NOR)", "Norway (NOR)", "United States (U...
## $ ref          <chr> "[2]", "[3]", "[4]", "[5]", "[6]", "[7]", "[8]", ...
## $ country      <chr> "France", "Switzerland", "United States", "German...
## $ countrycode  <chr> "FR", "CH", "US", "DE", "CH", "NO", "IT", "US", "...
## $ marker       <list> ["url(https://raw.githubusercontent.com/tugmaks/...
## $ flagicon     <chr> "https://raw.githubusercontent.com/tugmaks/flags/...
```

```r
urlimg <- "http://jkunst.com/images/add-style/winter_olimpics.jpg"
ttvars <- c("year", "nations", "sports", "competitors", "women", "men", "events")
tt <- tooltip_table(
  ttvars,
  sprintf("{point.%s}", ttvars), img = tags$img(src="{point.flagicon}", style = "text-align: center;")
)

hcgames2 <- hchart(dgames, "areaspline", hcaes(year, nations, name = host), name = "Nations") %>% 
  hc_colors(hex_to_rgba("white", 0.8)) %>% 
  hc_title(
    text = "Number of Participating Nations in every Winter Olympic Games",
    align = "left",
    style = list(color = "white")
  ) %>% 
  hc_credits(
    enabled = TRUE,
    text = "Data from Wipiedia",
    href = "https://en.wikipedia.org/wiki/Winter_Olympic_Games"
  ) %>% 
  hc_xAxis(
    title = list(text = "Time", style = list(color = "white")),
    gridLineWidth = 0,
    labels = list(style = list(color = "white"))
  ) %>% 
  hc_yAxis(
    lineWidth = 1,
    tickWidth = 1,
    tickLength = 10,
    title = list(text = "Nations", style = list(color = "white")),
    gridLineWidth = 0,
    labels = list(style = list(color = "white"))
  ) %>% 
  hc_chart(
    divBackgroundImage = urlimg,
    backgroundColor = hex_to_rgba("black", 0.10)
    ) %>% 
  hc_tooltip(
    headerFormat = as.character(tags$h4("{point.key}", tags$br())),
    pointFormat = tt,
    useHTML = TRUE,
    backgroundColor = "transparent",
    borderColor = "transparent",
    shadow = FALSE,
    style = list(color = "white", fontSize = "0.8em", fontWeight = "normal"),
    positioner = JS("function () { return { x: this.chart.plotLeft + 15, y: this.chart.plotTop + 0 }; }"),
    shape = "square"
  ) %>% 
  hc_plotOptions(
    series = list(
      states = list(hover = list(halo = list(size  = 30)))
    )
  ) %>% 
  hc_add_theme(hc_theme_elementary())

hcgames2
```

<!--html_preserve--><div id="htmlwidget-737320f704985553119d" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-737320f704985553119d">{
  "x": {
    "hc_opts": {
      "title": {
        "text": "Number of Participating Nations in every Winter Olympic Games",
        "align": "left",
        "style": {
          "color": "white"
        }
      },
      "yAxis": {
        "title": {
          "text": "Nations",
          "style": {
            "color": "white"
          }
        },
        "type": "linear",
        "lineWidth": 1,
        "tickWidth": 1,
        "tickLength": 10,
        "gridLineWidth": 0,
        "labels": {
          "style": {
            "color": "white"
          }
        }
      },
      "credits": {
        "enabled": true,
        "text": "Data from Wipiedia",
        "href": "https://en.wikipedia.org/wiki/Winter_Olympic_Games"
      },
      "exporting": {
        "enabled": false
      },
      "plotOptions": {
        "series": {
          "turboThreshold": 0,
          "showInLegend": false,
          "marker": {
            "enabled": true
          },
          "states": {
            "hover": {
              "halo": {
                "size": 30
              }
            }
          }
        },
        "treemap": {
          "layoutAlgorithm": "squarified"
        },
        "scatter": {
          "marker": {
            "symbol": "circle"
          }
        }
      },
      "series": [
        {
          "group": "group",
          "data": [
            {
              "games": "I",
              "year": 1924,
              "host": "Chamonix, France",
              "opened_by": "Undersecretary Gaston Vidal",
              "dates": "25 January  5 February",
              "nations": 16,
              "competitors": 258,
              "men": 247,
              "women": 11,
              "sports": 6,
              "disci_plines": 9,
              "events": 16,
              "top_nation": "Norway (NOR)",
              "ref": "[2]",
              "country": "France",
              "countrycode": "FR",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/FR.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/FR.png",
              "x": 1924,
              "y": 16,
              "name": "Chamonix, France"
            },
            {
              "games": "II",
              "year": 1928,
              "host": "St. Moritz, Switzerland",
              "opened_by": "President Edmund Schulthess",
              "dates": "1119 February",
              "nations": 25,
              "competitors": 464,
              "men": 438,
              "women": 26,
              "sports": 4,
              "disci_plines": 8,
              "events": 14,
              "top_nation": "Norway (NOR)",
              "ref": "[3]",
              "country": "Switzerland",
              "countrycode": "CH",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CH.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CH.png",
              "x": 1928,
              "y": 25,
              "name": "St. Moritz, Switzerland"
            },
            {
              "games": "III",
              "year": 1932,
              "host": "Lake Placid, United States",
              "opened_by": "Governor Franklin D. Roosevelt",
              "dates": "415 February",
              "nations": 17,
              "competitors": 252,
              "men": 231,
              "women": 21,
              "sports": 4,
              "disci_plines": 7,
              "events": 14,
              "top_nation": "United States (USA)",
              "ref": "[4]",
              "country": "United States",
              "countrycode": "US",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png",
              "x": 1932,
              "y": 17,
              "name": "Lake Placid, United States"
            },
            {
              "games": "IV",
              "year": 1936,
              "host": "Garmisch-Partenkirchen, Germany",
              "opened_by": "Chancellor Adolf Hitler",
              "dates": "616 February",
              "nations": 28,
              "competitors": 646,
              "men": 566,
              "women": 80,
              "sports": 4,
              "disci_plines": 8,
              "events": 17,
              "top_nation": "Norway (NOR)",
              "ref": "[5]",
              "country": "Germany",
              "countrycode": "DE",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/DE.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/DE.png",
              "x": 1936,
              "y": 28,
              "name": "Garmisch-Partenkirchen, Germany"
            },
            {
              "games": "V",
              "year": 1948,
              "host": "St. Moritz, Switzerland",
              "opened_by": "President Enrico Celio",
              "dates": "30 January  8 February",
              "nations": 28,
              "competitors": 669,
              "men": 592,
              "women": 77,
              "sports": 4,
              "disci_plines": 9,
              "events": 22,
              "top_nation": "Norway (NOR) Sweden (SWE)",
              "ref": "[6]",
              "country": "Switzerland",
              "countrycode": "CH",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CH.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CH.png",
              "x": 1948,
              "y": 28,
              "name": "St. Moritz, Switzerland"
            },
            {
              "games": "VI",
              "year": 1952,
              "host": "Oslo, Norway",
              "opened_by": "Princess Ragnhild",
              "dates": "1425 February",
              "nations": 30,
              "competitors": 694,
              "men": 585,
              "women": 109,
              "sports": 4,
              "disci_plines": 8,
              "events": 22,
              "top_nation": "Norway (NOR)",
              "ref": "[7]",
              "country": "Norway",
              "countrycode": "NO",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/NO.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/NO.png",
              "x": 1952,
              "y": 30,
              "name": "Oslo, Norway"
            },
            {
              "games": "VII",
              "year": 1956,
              "host": "Cortina d'Ampezzo, Italy",
              "opened_by": "President Giovanni Gronchi",
              "dates": "26 January  5 February",
              "nations": 32,
              "competitors": 821,
              "men": 687,
              "women": 134,
              "sports": 4,
              "disci_plines": 8,
              "events": 24,
              "top_nation": "Soviet Union (URS)",
              "ref": "[8]",
              "country": "Italy",
              "countrycode": "IT",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/IT.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/IT.png",
              "x": 1956,
              "y": 32,
              "name": "Cortina d'Ampezzo, Italy"
            },
            {
              "games": "VIII",
              "year": 1960,
              "host": "Squaw Valley, United States",
              "opened_by": "Vice President Richard Nixon",
              "dates": "1828 February",
              "nations": 30,
              "competitors": 665,
              "men": 521,
              "women": 144,
              "sports": 4,
              "disci_plines": 8,
              "events": 27,
              "top_nation": "Soviet Union (URS)",
              "ref": "[9]",
              "country": "United States",
              "countrycode": "US",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png",
              "x": 1960,
              "y": 30,
              "name": "Squaw Valley, United States"
            },
            {
              "games": "IX",
              "year": 1964,
              "host": "Innsbruck, Austria",
              "opened_by": "President Adolf Schärf",
              "dates": "29 January  9 February",
              "nations": 36,
              "competitors": 1091,
              "men": 892,
              "women": 199,
              "sports": 6,
              "disci_plines": 10,
              "events": 34,
              "top_nation": "Soviet Union (URS)",
              "ref": "[10]",
              "country": "Austria",
              "countrycode": "AT",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/AT.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/AT.png",
              "x": 1964,
              "y": 36,
              "name": "Innsbruck, Austria"
            },
            {
              "games": "X",
              "year": 1968,
              "host": "Grenoble, France",
              "opened_by": "President Charles de Gaulle",
              "dates": "618 February",
              "nations": 37,
              "competitors": 1158,
              "men": 947,
              "women": 211,
              "sports": 6,
              "disci_plines": 10,
              "events": 35,
              "top_nation": "Norway (NOR)",
              "ref": "[11]",
              "country": "France",
              "countrycode": "FR",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/FR.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/FR.png",
              "x": 1968,
              "y": 37,
              "name": "Grenoble, France"
            },
            {
              "games": "XI",
              "year": 1972,
              "host": "Sapporo, Japan",
              "opened_by": "Emperor Hirohito",
              "dates": "313 February",
              "nations": 35,
              "competitors": 1006,
              "men": 801,
              "women": 205,
              "sports": 6,
              "disci_plines": 10,
              "events": 35,
              "top_nation": "Soviet Union (URS)",
              "ref": "[12]",
              "country": "Japan",
              "countrycode": "JP",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/JP.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/JP.png",
              "x": 1972,
              "y": 35,
              "name": "Sapporo, Japan"
            },
            {
              "games": "XII",
              "year": 1976,
              "host": "Innsbruck, Austria",
              "opened_by": "President Rudolf Kirchschläger",
              "dates": "415 February",
              "nations": 37,
              "competitors": 1123,
              "men": 892,
              "women": 231,
              "sports": 6,
              "disci_plines": 10,
              "events": 37,
              "top_nation": "Soviet Union (URS)",
              "ref": "[13]",
              "country": "Austria",
              "countrycode": "AT",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/AT.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/AT.png",
              "x": 1976,
              "y": 37,
              "name": "Innsbruck, Austria"
            },
            {
              "games": "XIII",
              "year": 1980,
              "host": "Lake Placid, United States",
              "opened_by": "Vice President Walter Mondale",
              "dates": "1324 February",
              "nations": 37,
              "competitors": 1072,
              "men": 840,
              "women": 232,
              "sports": 6,
              "disci_plines": 10,
              "events": 38,
              "top_nation": "Soviet Union (URS)",
              "ref": "[14]",
              "country": "United States",
              "countrycode": "US",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png",
              "x": 1980,
              "y": 37,
              "name": "Lake Placid, United States"
            },
            {
              "games": "XIV",
              "year": 1984,
              "host": "Sarajevo, Yugoslavia",
              "opened_by": "President Mika piljak",
              "dates": "819 February",
              "nations": 49,
              "competitors": 1272,
              "men": 998,
              "women": 274,
              "sports": 6,
              "disci_plines": 10,
              "events": 39,
              "top_nation": "East Germany (GDR)",
              "ref": "[15]",
              "country": "Yugoslavia",
              "countrycode": "YU",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/YU.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/YU.png",
              "x": 1984,
              "y": 49,
              "name": "Sarajevo, Yugoslavia"
            },
            {
              "games": "XV",
              "year": 1988,
              "host": "Calgary, Canada",
              "opened_by": "Governor General Jeanne Sauvé",
              "dates": "1328 February",
              "nations": 57,
              "competitors": 1423,
              "men": 1122,
              "women": 301,
              "sports": 6,
              "disci_plines": 10,
              "events": 46,
              "top_nation": "Soviet Union (URS)",
              "ref": "[16]",
              "country": "Canada",
              "countrycode": "CA",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CA.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CA.png",
              "x": 1988,
              "y": 57,
              "name": "Calgary, Canada"
            },
            {
              "games": "XVI",
              "year": 1992,
              "host": "Albertville, France",
              "opened_by": "President François Mitterrand",
              "dates": "823 February",
              "nations": 64,
              "competitors": 1801,
              "men": 1313,
              "women": 488,
              "sports": 6,
              "disci_plines": 12,
              "events": 57,
              "top_nation": "Germany (GER)",
              "ref": "[17]",
              "country": "France",
              "countrycode": "FR",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/FR.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/FR.png",
              "x": 1992,
              "y": 64,
              "name": "Albertville, France"
            },
            {
              "games": "XVII",
              "year": 1994,
              "host": "Lillehammer, Norway",
              "opened_by": "King Harald V",
              "dates": "1227 February",
              "nations": 67,
              "competitors": 1737,
              "men": 1215,
              "women": 522,
              "sports": 6,
              "disci_plines": 12,
              "events": 61,
              "top_nation": "Russia (RUS)",
              "ref": "[18]",
              "country": "Norway",
              "countrycode": "NO",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/NO.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/NO.png",
              "x": 1994,
              "y": 67,
              "name": "Lillehammer, Norway"
            },
            {
              "games": "XVIII",
              "year": 1998,
              "host": "Nagano, Japan",
              "opened_by": "Emperor Akihito",
              "dates": "722 February",
              "nations": 72,
              "competitors": 2176,
              "men": 1389,
              "women": 787,
              "sports": 7,
              "disci_plines": 14,
              "events": 68,
              "top_nation": "Germany (GER)",
              "ref": "[19]",
              "country": "Japan",
              "countrycode": "JP",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/JP.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/JP.png",
              "x": 1998,
              "y": 72,
              "name": "Nagano, Japan"
            },
            {
              "games": "XIX",
              "year": 2002,
              "host": "Salt Lake City, United States",
              "opened_by": "President George W. Bush",
              "dates": "824 February",
              "nations": 78,
              "competitors": 2399,
              "men": 1513,
              "women": 886,
              "sports": 7,
              "disci_plines": 15,
              "events": 78,
              "top_nation": "Norway (NOR)",
              "ref": "[20]",
              "country": "United States",
              "countrycode": "US",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/US.png",
              "x": 2002,
              "y": 78,
              "name": "Salt Lake City, United States"
            },
            {
              "games": "XX",
              "year": 2006,
              "host": "Turin, Italy",
              "opened_by": "President Carlo Azeglio Ciampi",
              "dates": "1026 February",
              "nations": 80,
              "competitors": 2508,
              "men": 1548,
              "women": 960,
              "sports": 7,
              "disci_plines": 15,
              "events": 84,
              "top_nation": "Germany (GER)",
              "ref": "[21]",
              "country": "Italy",
              "countrycode": "IT",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/IT.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/IT.png",
              "x": 2006,
              "y": 80,
              "name": "Turin, Italy"
            },
            {
              "games": "XXI",
              "year": 2010,
              "host": "Vancouver, Canada",
              "opened_by": "Governor General Michaëlle Jean",
              "dates": "1228 February",
              "nations": 82,
              "competitors": 2566,
              "men": 1522,
              "women": 1044,
              "sports": 7,
              "disci_plines": 15,
              "events": 86,
              "top_nation": "Canada (CAN)",
              "ref": "[22]",
              "country": "Canada",
              "countrycode": "CA",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CA.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/CA.png",
              "x": 2010,
              "y": 82,
              "name": "Vancouver, Canada"
            },
            {
              "games": "XXII",
              "year": 2014,
              "host": "Sochi, Russia",
              "opened_by": "President Vladimir Putin",
              "dates": "723 February",
              "nations": 88,
              "competitors": 2873,
              "men": 1714,
              "women": 1159,
              "sports": 7,
              "disci_plines": 15,
              "events": 98,
              "top_nation": "Russia (RUS)",
              "ref": "[23]",
              "country": "Russia",
              "countrycode": "RU",
              "marker": {
                "symbol": "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/RU.png)"
              },
              "flagicon": "https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/RU.png",
              "x": 2014,
              "y": 88,
              "name": "Sochi, Russia"
            }
          ],
          "type": "areaspline",
          "name": "Nations"
        }
      ],
      "xAxis": {
        "type": "linear",
        "title": {
          "text": "Time",
          "style": {
            "color": "white"
          }
        },
        "gridLineWidth": 0,
        "labels": {
          "style": {
            "color": "white"
          }
        }
      },
      "colors": [
        "rgba(255,255,255,0.8)"
      ],
      "chart": {
        "divBackgroundImage": "http://jkunst.com/images/add-style/winter_olimpics.jpg",
        "backgroundColor": "rgba(0,0,0,0.1)"
      },
      "tooltip": {
        "headerFormat": "<h4>\n  {point.key}\n  <br/>\n\u003c/h4>",
        "pointFormat": "<table>\n  <tr>\n    <th>year\u003c/th>\n    <td>{point.year}\u003c/td>\n  \u003c/tr>\n  <tr>\n    <th>nations\u003c/th>\n    <td>{point.nations}\u003c/td>\n  \u003c/tr>\n  <tr>\n    <th>sports\u003c/th>\n    <td>{point.sports}\u003c/td>\n  \u003c/tr>\n  <tr>\n    <th>competitors\u003c/th>\n    <td>{point.competitors}\u003c/td>\n  \u003c/tr>\n  <tr>\n    <th>women\u003c/th>\n    <td>{point.women}\u003c/td>\n  \u003c/tr>\n  <tr>\n    <th>men\u003c/th>\n    <td>{point.men}\u003c/td>\n  \u003c/tr>\n  <tr>\n    <th>events\u003c/th>\n    <td>{point.events}\u003c/td>\n  \u003c/tr>\n\u003c/table>\n<img src=\"{point.flagicon}\" style=\"text-align: center;\"/>",
        "useHTML": true,
        "backgroundColor": "transparent",
        "borderColor": "transparent",
        "shadow": false,
        "style": {
          "color": "white",
          "fontSize": "0.8em",
          "fontWeight": "normal"
        },
        "positioner": "function () { return { x: this.chart.plotLeft + 15, y: this.chart.plotTop + 0 }; }",
        "shape": "square"
      }
    },
    "theme": {
      "colors": [
        "#41B5E9",
        "#FA8832",
        "#34393C",
        "#E46151"
      ],
      "chart": {
        "style": {
          "color": "#333",
          "fontFamily": "Open Sans"
        }
      },
      "title": {
        "style": {
          "fontFamily": "Raleway",
          "fontWeight": "100"
        }
      },
      "subtitle": {
        "style": {
          "fontFamily": "Raleway",
          "fontWeight": "100"
        }
      },
      "legend": {
        "align": "right",
        "verticalAlign": "bottom"
      },
      "xAxis": {
        "gridLineWidth": 1,
        "gridLineColor": "#F3F3F3",
        "lineColor": "#F3F3F3",
        "minorGridLineColor": "#F3F3F3",
        "tickColor": "#F3F3F3",
        "tickWidth": 1
      },
      "yAxis": {
        "gridLineColor": "#F3F3F3",
        "lineColor": "#F3F3F3",
        "minorGridLineColor": "#F3F3F3",
        "tickColor": "#F3F3F3",
        "tickWidth": 1
      }
    },
    "conf_opts": {
      "global": {
        "Date": null,
        "VMLRadialGradientURL": "http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png",
        "canvasToolsURL": "http =//code.highcharts.com/list(version)/modules/canvas-tools.js",
        "getTimezoneOffset": null,
        "timezoneOffset": 0,
        "useUTC": true
      },
      "lang": {
        "contextButtonTitle": "Chart context menu",
        "decimalPoint": ".",
        "downloadJPEG": "Download JPEG image",
        "downloadPDF": "Download PDF document",
        "downloadPNG": "Download PNG image",
        "downloadSVG": "Download SVG vector image",
        "drillUpText": "Back to {series.name}",
        "invalidDate": null,
        "loading": "Loading...",
        "months": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
        "noData": "No data to display",
        "numericSymbols": ["k", "M", "G", "T", "P", "E"],
        "printChart": "Print chart",
        "resetZoom": "Reset zoom",
        "resetZoomTitle": "Reset zoom level 1:1",
        "shortMonths": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        "thousandsSep": " ",
        "weekdays": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
      }
    },
    "type": "chart",
    "fonts": ["Open+Sans", "Raleway"],
    "debug": true
  },
  "evals": ["hc_opts.tooltip.positioner"],
  "jsHooks": []
}</script><!--/html_preserve-->


---
title: "readme.R"
author: "Joshua"
date: "Fri Mar 03 00:41:45 2017"
---
