#' ---
#' title: "How to: Weather Radials"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")

library("dplyr")
library("readr")
library("highcharter")
library("stringr")
library("lubridate")
library("jbkmisc")
blog_setup()

#' 
#' TLDR: Creating weather radials with highcarter and ggplot2.
#' 
#' I was surfing by the deep seas of the web and I found the *Brice Pierre de la Briere*'s 
#' [blocks](http://bl.ocks.org/bricedev) and I saw the *weather radials* which originally are
#' [poster collection](http://weather-radials.com/). Brice use D3 and he used D3 very well
#' and I love D3 but I'm in a rookie level to do something like him. **D3 is not for everybody**
#' and surely not for me, I would love to lear more but family, work and R has priority over D3 so
#' how can I do something like that. Well I have highcarter. So let's try. 
#' 
#' We'll use the same data as Brice (https://www.wunderground.com/).

df <- read_csv("http://bl.ocks.org/bricedev/raw/458a01917183d98dff3c/sf.csv")

df[1:4, 1:4]

names(df) <- names(df) %>% 
  str_to_lower() %>% 
  str_replace("\\s+", "_")

df <- df %>% 
  mutate(id = seq(nrow(df)),
         date2 = as.Date(ymd(date)),
         tmstmp = datetime_to_timestamp(date2),
         month = month(ymd(date)))

dsmax <- df %>%
  select(x = tmstmp,
         y = max_temperaturec) %>% 
  list.parse3()
 
dsmin <- df %>% 
  select(x = tmstmp, y = min_temperaturec) %>% 
  list.parse3()


#' 
#' ## First try
#' 
#' Here we test and chart the data in the most simple way. A line time.
#'  
hc <- highchart() %>% 
  hc_chart(
    type = "line"
    ) %>%
  hc_xAxis(
    type = "datetime",
    tickInterval = 30 * 24 * 3600 * 1000,
    labels = list(format = "{value: %b}")
  ) %>% 
  hc_yAxis(
    min = 0,
    labels = list(format = "{value}°C")
  ) %>% 
  hc_add_series(
    data = dsmax, name = "max"
  ) %>% 
  hc_add_series(
    data = dsmin, name = "min"
    ) %>% 
  hc_add_theme(
    hc_theme_smpl()
    )

hc

#' 
#' Everything seem fine.
#' 
#' ## Second Step
#' 
#' We' change the type to column, stack and see what is the result
#' 


hc <- hc %>% 
  hc_chart(
    type = "column"
    ) %>% 
  hc_plotOptions(
    series = list(
      stacking = "normal"
    )
  )

hc

#' 
#' Not so close.
#' 
#' ## Final Step
#' 
#' If you see the previous chart we stacked so we sum the min and max 
#' and the data don't reflect the value (min,max) what we want. 
#' So we need to create the difference between the max and min, 
#' and plot them with the min value and hiding using a transparent color.
#'   


dsmax <- df %>% 
  mutate(color = colorize_vector(mean_temperaturec, "A"),
         y = max_temperaturec - min_temperaturec) %>% 
  select(x = tmstmp,
         y,
         name = date,
         color,
         mean = mean_temperaturec,
         max = max_temperaturec,
         min = min_temperaturec) %>% 
  list.parse3()


# Some tooltips to make it a little *intercative*
x <- c("Min", "Mean", "Max")
y <- sprintf("{point.%s}", tolower(x))
tltip <- tooltip_table(x, y)

hc <- highchart() %>% 
  hc_chart(
    type = "column",
    polar = TRUE
  ) %>%
  hc_plotOptions(
    series = list(
      stacking = "normal",
      showInLegend = FALSE
    )
  ) %>% 
  hc_xAxis(
    gridLineWidth = 0.5,
    type = "datetime",
    tickInterval = 30 * 24 * 3600 * 1000,
    labels = list(format = "{value: %b}")
  ) %>% 
  hc_yAxis(
    max = 30,
    min = -10,
    labels = list(format = "{value}°C"),
    showFirstLabel = FALSE
    ) %>% 
  hc_add_series(
    data = dsmax
  ) %>% 
  hc_add_series(
    data = dsmin,
    color = "transparent",
    enableMouseTracking = FALSE
  ) %>% 
  hc_add_theme(
    hc_theme_smpl()
  ) %>% 
  hc_tooltip(
    useHTML = TRUE,
    headerFormat = as.character(tags$small("{point.x:%d %B, %Y}")),
    pointFormat = tltip
  )

hc

#' 
#' Yay :D! A beautiful chart same as the d3 version and only using R. So sweet!
#'
#' I'm happy with the result. This is not a standar chart but is
#' a king of *artistic*. What do you think? Any other examples to test
#' this type of chart?
#' 
#' ## Bonus Track: ggplot2 version
#' 
#' It's *really really* easy to do this type of chart in ggplot2 using
#' `geom_linerange` and `geom_polar`:

library("ggplot2")
library("viridis")
library("scales")

ggplot(df, aes(date2,
               ymin = min_temperaturec,
               ymax = max_temperaturec,
               color = mean_temperaturec)) + 
  geom_linerange(size = 1.3, alpha = 0.75) +
  scale_color_viridis(NULL, option = "A") +
  scale_x_date(labels = date_format("%b"), breaks = date_breaks("month")) + 
  ylim(-10, 35) + 
  labs(title = "San Francisco Wather Radial",
       subtitle = "It would be nice if someone do this with the animation package",
       caption = "Other example for ggplot2 vs base #boring but #fun",
       x = NULL, y = NULL) +
  coord_polar() + 
  theme_jbk() +
  theme(legend.position = "bottom")

#' Nice!
#' 
#' Searching I found someone do 
#' [this](https://www.quora.com/R-programming-language/What-is-the-most-elegant-plot-you-have-made-using-ggplot2):
#' 
#' > Always exist someone who did what you did before you.
#' 
#' At least I share the code! :D.

