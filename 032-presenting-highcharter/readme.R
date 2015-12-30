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

#' [Highcharts](http://highcharts.com) was the first javascript library what I used in a long time
#' ago. Highchartshave a mature API to plot a lot of types of charts. Obviously there are some R 
#' packages to plot data using this library:
#' 
#' - [Ramnath Vaidyanathan](https://github.com/ramnathv)'s [rCharts](https://github.com/ramnathv/rCharts).
#' What a library. This was the beginning to the R & JS romance. The rCharts approach to plot data
#' is object oriented; here we used a lot of `chart$Key(arguments, ...)`.
#' - [highchartR](https://github.com/jcizel/highchartR) package from [jcizel](https://github.com/jcizel).
#' This package we use the `highcharts` function and give some parameters, like the variable's names get our
#' chart.
#' 
#' With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?**. 
#' The main reasons were:
#' 
#' - Write/code highcharts plots using the piping style and get similar results like 
#' [dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
#' [taucharts](http://rpubs.com/hrbrmstr/taucharts),[leaflet](https://rstudio.github.io/leaflet/)
#' packages.
#' - Get a way to get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts)
#' including *themes* and *options* too.
#' - Generate shortcuts for some R objects. For example time series.
#' - Put all my love for highcharts in somewhere.
#' 
#' The result? I don't know yet. The users will be judges. I'm just here to show you what can you 
#' do with this package. So here we go with the demos!
#' 
#' ### The Demo ####

library("highcharter")
library("magrittr")
library("dplyr")

data("citytemp")

citytemp

hc <- highchart() %>% 
  hc_add_serie(name = "tokyo", data = citytemp$tokyo)

hc

#' Very simple chart. Here comes the powerful highchart API.

hc <- hc %>% 
  hc_title(text = "Temperatures for some cities") %>% 
  hc_xAxis(categories = citytemp$month) %>% 
  hc_add_serie(name = "London", data = citytemp$london,
               dataLabels = list(enabled = TRUE)) %>% 
  hc_yAxis(title = list(text = "Temperature"),
           labels = list(format = "{value}° C")) 
  
hc

#' And finally we can add a theme.

hc <- hc %>% 
  hc_add_serie(name = "New York", data = citytemp$new_york, type = "spline") %>% 
  hc_add_theme(hc_theme_sandsignika())
  
hc


#' ### Some shortcuts ####

#' For ts objects

highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") %>% 
  hc_add_theme(hc_theme_darkunica())




#' ### With Great Power Comes Great Responsibility ####

#' ![Save pie!](http://cdn.meme.am/instances2/500x/3594501.jpg)
#' 
#' You can use this pacakge for evil purposes so be careful

iriscount <- count(iris, Species)
iriscount

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
