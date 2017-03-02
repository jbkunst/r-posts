#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "",
                      fig.showtext = TRUE, dev = "CairoPNG")

#' # Preliminars
library(tidyverse) 
library(highcharter)
library(lubridate)
library(rvest)
library(janitor)
library(stringr)
library(jsonlite)
library(countrycode)

options(highcharter.debug = TRUE)

#' # Example I: Winter Olympic Games
tables <- read_html("https://en.wikipedia.org/wiki/Winter_Olympic_Games") %>% 
  html_table(fill = TRUE)

dgames <- tables[[5]]
dgames <- clean_names(dgames)

dgames <- dgames[-1, ]
dgames <- filter(dgames, !games %in% c("1940", "1944"))
dgames <- filter(dgames, !year %in% seq(2018, by = 4, length.out = 4))


# not sure how re-read data to get correct types
tf <- tempfile(fileext = ".csv")
write_csv(dgames, tf)
dgames <- read_csv(tf)

dgames <- mutate(dgames,
                 nations = str_extract(nations, "\\d+"),
                 nations = as.numeric(nations))

count(dgames, country)
dgames

glimpse(dgames)

hcgames <- hchart(dgames, "areaspline", hcaes(year, nations, name = host), name = "Nations")
hcgames


urlico <- "url(https://raw.githubusercontent.com/tugmaks/flags/2d15d1870266cf5baefb912378ecfba418826a79/flags/flags-iso/flat/24/%s.png)"
urlimg <- "http://jkunst.com/images/add-style/winter_olimpics.jpg"

dgames <- dgames %>% 
  mutate(country = str_extract(host, ", .*$"),
         country = str_replace(country, ", ", ""),
         country = str_trim(country)) %>% 
  mutate(countrycode = countrycode(country, origin = "country.name", destination = "iso2c")) %>% 
  mutate(marker = sprintf(urlico, countrycode),
         marker = map(marker, function(x) list(symbol = x)),
         flagicon = sprintf(urlico, countrycode),
         flagicon = str_replace_all(flagicon, "url\\(|\\)", ""))

glimpse(dgames)

ttvars <- c("host", "nations", "sports", "competitors", "events")

tt <- tooltip_table(
  ttvars,
  sprintf("{point.%s}", ttvars) #, img = tags$img(src="{point.flagicon}")
)

cat(tt)

hcgames2 <- hchart(dgames, "areaspline", hcaes(year, nations), name = "Nations") %>% 
  hc_add_theme(hc_theme_smpl()) %>% 
  hc_colors(hex_to_rgba("white", 0.8)) %>% 
  hc_xAxis(
    title = list(text = ""),
    gridLineWidth = 0,
    labels = list(style = list(color = "white"))
  ) %>% 
  hc_yAxis(
    lineWidth = 1,
    tickWidth = 1,
    tickLength = 10,
    title = list(text = ""),
    gridLineWidth = 0,
    labels = list(style = list(color = "white"))
  ) %>% 
  hc_chart(
    divBackgroundImage = urlimg,
    backgroundColor = hex_to_rgba("black", 0.10)
    ) %>% 
  hc_tooltip(
    pointFormat = tt,
    useHTML = TRUE,
    backgroundColor = "transparent",
    borderColor = "transparent",
    shadow = FALSE,
    style = list(color = "white", fontSize = "0.8em"),
    positioner = JS("function () { return { x: this.chart.plotLeft + 30, y: this.chart.plotTop + 30 }; }"),
    shape = "square"
  ) %>% 
  hc_plotOptions(
    series = list(
      states = list(hover = list(halo = list(size  = 30)))
    )
  )
hcgames2


#' # Example II: Oil Spilss
#' 
#' # https://ourworldindata.org/oil-spills/#data-sources
#' 
json <- read_lines("https://ourworldindata.org/wp-content/uploads/nvd3/nvd3_multiBarChart_Oil/multiBarChart_Oil.html")
json <- json[seq(
  which(str_detect(json, "var xxx")),
  first(which(str_detect(json, "\\}\\]\\;")))
)]

json <- fromJSON(str_replace_all(json, "var xxx = |;$", ""))
json <- transpose(json)

str(json)

dspills <- map_df(json, function(x) {
  df <- as.data.frame(x[["values"]])
  df$key <- x[["key"]]
  tbl_df(df)
  df
})

glimpse(dspills)

urlimg <- "http://ocean.nationalgeographic.com/u/TvyamNb-BivtNwpvn7Sct0VFDulyAfA9wBcU0gVHVnqC5ghqXjggeitqtJ-1ZIZ1rmCgor42TXOteIQU/"
# urlimg <- "http://6iee.com/data/uploads/11/693547.jpg"
# urlimg <- "http://68.media.tumblr.com/21b140a3cdd69eeae22aee32642ca656/tumblr_o2o8h8nsmd1u8z9hho1_1280.jpg"
urlimg <- "http://www.drodd.com/images14/ocean-wallpaper30.jpg"


hcspills <- hchart(dspills, "areaspline", hcaes(x, y, group = "key")) %>% 
  hc_plotOptions(series = list(stacking = "normal"))
hcspills

hcspills2 <- hcspills %>% 
  hc_colors(c("#000000", "#222222")) %>% 
  hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>% 
  hc_chart(
    divBackgroundImage = urlimg,
    backgroundColor = hex_to_rgba("white", 0.50)
  ) %>% 
  hc_tooltip(sort = TRUE, table = TRUE) %>% 
  hc_xAxis(type = "datetime", opposite = TRUE) %>% 
  hc_yAxis(reversed = TRUE, gridLineWidth = 0) 
hcspills2



