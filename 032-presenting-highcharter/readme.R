#' ---
#' title: "Presenting Highcharter"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    theme: journal
#'    toc: false
#'    keep_md: yes
#' ---


#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())

#' After a lot of documentation, `R CMD check`s and a lot of patience from CRAN
#' people I'm happy to anonounce [highcharter](http://jkunst.com/highcharter) v0.1.0:
#' A(nother) wrapper for [Highcharts](http://highcharts.com) charting library.
#' 
#' [I like Highcharts(http://jkunst.com/r/ggplot-with-a-highcharts-taste/). It was the 
#' first charting javascript library what I used in a long time and have
#' very a mature API to plot a lot of types of charts. Obviously there are some R 
#' packages to plot data using this library:
#' 
#' - [Ramnath Vaidyanathan](https://github.com/ramnathv)'s [rCharts](https://github.com/ramnathv/rCharts).
#' What a library. This was the beginning to the R & JS romance. The `rCharts` approach to plot data
#' is object oriented; here we used a lot of `chart$Key(arguments, ...)`.
#' - [highchartR](https://github.com/jcizel/highchartR) package from [jcizel](https://github.com/jcizel).
#' This package we use the `highcharts` function and give some parameters, like the variable's names get our
#' chart.
#' 
#' With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?**. 
#' The main reasons were/are:
#' 
#' - Write/code highcharts plots using the piping style and get similar results like 
#' [dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
#' [taucharts](http://rpubs.com/hrbrmstr/taucharts), [leaflet](https://rstudio.github.io/leaflet/)
#' packages.
#' - Get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts).  
#' This mean we have here a *raw* wrapper in the sense that you maybe need to make/construct the chart by hand
#' not so R user friendly but with some shortcuts to plot R objects. So you can plot  
#' including [*themes*](http://jkunst.com/highcharter/#themes) and *options*.
#' - Generate shortcuts for some R objects. For example time series.
#' - Put all my love for highcharts in somewhere.
#' 
#' The result? I don't know yet. The users will be judges. I'm just here to show you what can you 
#' do with this package. So here we go with the demos!
#' 
#' ### The Demo ####
#' 
#' Let's see a simple chart.
#' 
#+ message=FALSE, warning=FALSE
library("highcharter")
library("magrittr")
library("dplyr")

data("citytemp")

citytemp

hc <- highchart() %>% 
  hc_add_serie(name = "tokyo", data = citytemp$tokyo)

hc

#' Very simple chart. Here comes the powerful highchart API: Adding more series
#' data and adding themes.

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
  

#' ### Some examples ####

#' For ts objects

highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") 

#' A more elaborated xample
#' 
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


#' ### You can do anything ####

#' As uncle Bem said some day:
#' 
#' ![SavePie](https://raw.githubusercontent.com/jbkunst/r-posts/master/032-presenting-highcharter/save%20pie.jpg)
#' 
#' You can use this pacakge for evil purposes so be careful

iriscount <- count(iris, Species)
iriscount

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

#+ echo=FALSE, results='hide'

# DONT FORGET

ds <- iris %>% 
  count(Species) %>% 
  purrr::map_if(is.factor, as.character) %>% 
  rlist::list.parse() %>% 
  purrr::map(function(x){ setNames(x, NULL) }) %>% 
  setNames(NULL)

highchart() %>% 
  hc_title(text = "Edgar Anderson's Iris Data") %>%
  hc_xAxis(title = list(text = "Sepal Length")) %>% 
  hc_yAxis(title = list(text = "Sepal Width")) %>%
  hc_add_serie_scatter(iris$Sepal.Length, iris$Sepal.Width, iris$Species) %>% 
  hc_add_serie_labels_values(iriscount$Species, iriscount$n, type = "pie", name = "Total",
                             colorByPoint = TRUE, center = c('80%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_add_theme(hc_theme_sandsignika())


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
