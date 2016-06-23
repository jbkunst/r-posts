#' ---
#' title: "Anima Temperatures"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#' 
#' Time time ago an gif appears showing the change of the global temperatures
#' over time.
#' 
#' <img src="https://i.kinja-img.com/gawker-media/image/upload/s--sy8MLJrE--/c_scale,fl_progressive,q_80,w_800/oo0q9awrmmsctypfh6yb.gif" width="350px">
#' 
#' Well, some sites like http://gizmodo.com/ made a reference to this animation
#' as [one-of-the-most-convincing-climate-change-visualization](http://gizmodo.com/one-of-the-most-convincing-climate-change-visualization-1775743779).
#' Mmmm... ok! A kind of *click bait* IMHO but at least the title saids visualization :B. But for me the 
#' animation don't work **always**. I rembember a quote, sadly I don't rember the author, may be/surely was
#' Alberto Cairo (If you know it please tell me who was):
#' 
#' > Animation force the user to compare what they see with what they remember (saw).
#' 
#' If you want it in Yoda's way:
#' 
#' <img src="https://i.imgflip.com/16a5b7.jpg" width="400px">
#' 
#' Other thing I don't like so much about this spiral is there'are so much data 
#' overlaped at the end of animation hiding information about the speed of increment 
#' in the data.
#' 
#' So this post will be about if we can show this data in other ways to **try** to 
#' tell more clearly the **Oh! *Foo!* is this rly happening?** story.
#' 


#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.showtext = TRUE, dev = "CairoPNG")
library("printr")
library("jbkmisc")
#'
#' ## Data  & Packages
#' 
#' We'll use the data provide by [hrbrmstr](https://twitter.com/hrbrmstr) in his 
#' [repo](https://github.com/hrbrmstr/hadcrut).
#' Bob Rudis made a beautiful representation of the data via ggplot2 and D3 using a 
#' `geom_segment`/column range viz.
#' 
#' About the packages. Here we'll use a lot of `dplyr`, `tidyr`, `purrr` for the data manipulation,
#' for the colors we'll use `viridis`, lastly I'll use [`highcharter`](jkunst.com/highcharter)
#' for charts 
#'   

library("highcharter")
library("readr")
library("dplyr")
library("tidyr")
library("lubridate")
library("purrr")
library("viridis")

options(
  highcharter.theme = hc_theme_darkunica(
    chart  = list(style = list(fontFamily = "Roboto Condensed")),
    plotOptions = list(series = list(showInLegend = FALSE))
  )
)

df <- read_csv("https://raw.githubusercontent.com/hrbrmstr/hadcrut/master/data/temps.csv")

df <- df %>% 
  mutate(date = ymd(year_mon),
         tmpstmp = datetime_to_timestamp(date),
         year = year(date),
         month = month(date, label = TRUE),
         color_m = colorize(median, viridis(10)),
         color_m = hex_to_rgba(color_m, 0.65))

dfcolyrs <- df %>% 
  group_by(year) %>% 
  summarise(median = median(median)) %>% 
  ungroup() %>% 
  mutate(color_y = colorize(median, viridis(10)),
         color_y = hex_to_rgba(color_y, 0.65)) %>% 
  select(-median)

df <- left_join(df, dfcolyrs, by = "year")

#'
#' The data is ready, let's go.
#' 
#' 

#+echo=FALSE
head(df)

#'
#' ## Spiral
#' 
#' First of all let's try to replicate the chart/gif/animation that's reason
#' to write this post. Here we'll construtct a `list` of series to use 
#' with `hc_add_series_list` function.
#' 
lsseries <- df %>% 
  group_by(year) %>% 
  do(
    data = .$median,
    color = first(.$color_y)) %>% 
  mutate(name = year) %>% 
  list.parse3()

hc1 <- highchart() %>% 
  hc_chart(polar = TRUE) %>% 
  hc_plotOptions(
    series = list(
      marker = list(enabled = FALSE),
      animation = TRUE,
      pointIntervalUnit = "month")
    ) %>%
  hc_legend(enabled = FALSE) %>% 
  hc_xAxis(type = "datetime", min = 0, max = 365 * 24 * 36e5,
           labels = list(format = "{value:%B}")) %>%
  hc_tooltip(headerFormat = "{point.key}",
             xDateFormat = "%B",
             pointFormat = " {series.name}: {point.y}") %>% 
  hc_add_series_list(lsseries)

hc1

#'
#' Ok! without the animation componet this don't work so much.
#' 
#' ### Spiral w/animation
#' 
#' If we want replicate the animation part we can hide all the series 
#' using transparency.

lsseries2 <- df %>% 
  group_by(year) %>% 
  do(
    data = .$median,
    color = "transparent",
    enableMouseTracking = FALSE,
    color2 = first(.$color_y)) %>% 
  mutate(name = year) %>% 
  list.parse3()

#' 
#' Then using a little of javascript we can color each series 
#' one by one with the real color.
#' 

hc11 <- highchart() %>% 
  hc_chart(polar = TRUE) %>% 
  hc_plotOptions(series = list(
    marker = list(enabled = FALSE),
    animation = TRUE,
    pointIntervalUnit = "month")) %>%
  hc_legend(enabled = FALSE) %>% 
  hc_xAxis(type = "datetime", min = 0, max = 365 * 24 * 36e5,
           labels = list(format = "{value:%B}")) %>%
  hc_tooltip(headerFormat = "{point.key}", xDateFormat = "%B",
             pointFormat = " {series.name}: {point.y}") %>% 
  hc_add_series_list(lsseries2) %>% 
  hc_chart(
    events = list(
      load = JS("

function() {
  console.log('ready');
  var duration = 16 * 1000
  var delta = duration/this.series.length;
  var delay = 0;

  this.series.map(function(e){
    setTimeout(function() {
      e.update({color: e.options.color2, enableMouseTracking: true});
      e.chart.setTitle(null, {text: e.name})
    }, delay)
    delay = delay + delta;
  });
}
                ")
    )
  )

# rm theme
hc11$x$theme <- list(chart = list(divBackgroundImage = NULL))

#'
#' And voilà
#'

hc11

#'
#' You can open the chart in a new window to see the animation effect.
#'
#' ## Sesonalplot
#' 
#' We need polar coords here? I don't know so let's back 
#' to the euclidean space and see what happend
#' 
hc2 <- hc1 %>% 
  hc_chart(polar = FALSE, type = "spline") %>% 
  hc_xAxis(max = (365 - 1) * 24 * 36e5)

hc2

#' 
#' **Ñom!** A nice colored spaghettis. Not so much clear what happended
#' across the years. 
#' 
#' 
#' ## Heatmap
#' 
#' Here we put the years in xAxis and month in yAxis:
#' 
m <- df %>% 
  select(year, month, median) %>% 
  spread(year, median) %>% 
  select(-month) %>% 
  as.matrix() 

rownames(m) <- month.abb

hc3 <- hchart(m) %>% 
  hc_colorAxis(stops = color_stops(10, viridis(10))) %>% 
  hc_yAxis(title = list(text = NULL))

hc3

#'
#' With the color scale used is not that clear the impact 
#' about the incremet. We can see the series have and increase 
#' but with colors is not so easy to quantify that change.
#' 
#'
#' ## Line / Time Series
#' 
#' Let's try now the most simply chart. And let's represent
#' the data as a time series.
#' 
dsts <- df %>% 
  mutate(name = paste(decade, month)) %>% 
  select(x = tmpstmp, y = median, name)

hc4 <- highchart() %>% 
  hc_xAxis(type = "datetime") %>%
  hc_add_series_df(dsts, name = "Global Temperature",
                   type = "line", color = hex_to_rgba("#90ee7e", 0.5),
                   lineWidth = 1,
                   states = list(hover = list(lineWidth = 1)),
                   shadow = FALSE) 
hc4

#' 
#' May be it's so simple. What do you think?
#'
#' ## Columrange
#' 
#' Finally let's add the information about the confidence interval and
#' add the media information using a color same as 
#' [hrbrmstr](https://twitter.com/hrbrmstr) did.
#' 
#' With highcharter it's easy. Just define the dataframe with `x`,
#' `low`, `high` and `color` and add it to a `highchart` object 
#' with the `hc_add_series_df` function.
#' 
dscr <- df %>% 
  mutate(name = paste(decade, month)) %>% 
  select(x = tmpstmp, low = lower, high = upper, name, color = color_m)

hc5 <- highchart() %>% 
  hc_xAxis(type = "datetime") %>%
  hc_add_series_df(dscr, name = "Global Temperature",
                   type = "columnrange")

hc5

#'
#' (IMHO) This is the best way to show what we want to say:
#' 
#' * Via a time series chart it's wasy compare the past with the 
#' actual period of time.
#' * The color, in particular the last *yellowish* part, add importance and guide our
#' eyes to that part of the chart before to start to compare.
#' 

#+ echo=FALSE
giphy("RgfGmnVvt8Pfy")

#' 
#' Do you have other ways to represent this data?
#' 


