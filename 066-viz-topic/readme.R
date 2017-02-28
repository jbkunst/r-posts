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

#'
#' # Data
#'
library(tidyverse) 
library(highcharter)
library(lubridate)
library(rvest)
library(janitor)
library(stringr)
# options(highcharter.theme = hc_theme_smpl())

tables <- read_html("https://en.wikipedia.org/wiki/Winter_Olympic_Games") %>% 
  html_table(fill = TRUE)


# map(tables, dim)

data <- tables[[5]]
data <- clean_names(data)

data <- data[-1, ]
data <- filter(data, !games %in% c("1940", "1944"))
data <- filter(data, !year %in% seq(2018, by = 4, length.out = 4))


# not sure how re-read data to get correct types
tf <- tempfile(fileext = ".csv")
write_csv(data, tf)
data <- read_csv(tf)

data <- mutate(data,
               nations = str_extract(nations, "\\d+"),
               nations = as.numeric(nations))
data


urlimg <- "http://jkunst.com/images/add-style/winter_olimpics.jpg"

hchart(data, "area", hcaes(year, nations),
       name = "Nations", color = hex_to_rgba("white", 0.8), fillColor = hex_to_rgba("white", 0.7)) %>% 
  hc_xAxis(title = list(text = ""), crosshair = TRUE) %>% 
  hc_yAxis(title = list(text = "")) %>% 
  hc_add_theme(
    hc_theme(
      chart = list(
        divBackgroundImage = urlimg,
        backgroundColor = hex_to_rgba("white", 0.10)
        ),
      yAxis = list(
        gridLineWidth = 0
        ),
      xAxis = list(
        opposite = TRUE
      )
      )
    ) 



# numer two ---------------------------------------------------------------
library(stringr)
library(jsonlite)

json <- read_lines("https://ourworldindata.org/wp-content/uploads/nvd3/nvd3_multiBarChart_Oil/multiBarChart_Oil.html")
json <- json[seq(
  which(str_detect(json, "var xxx")),
  first(which(str_detect(json, "\\}\\]\\;")))
)]

json <- fromJSON(str_replace_all(json, "var xxx = |;$", ""))
json <- transpose(json)

str(json)

data <- map_df(json, function(x) {
  df <- as.data.frame(x[["values"]])
  df$key <- x[["key"]]
  tbl_df(df)
})

data

urlimg <- "http://ocean.nationalgeographic.com/u/TvyamNb-BivtNwpvn7Sct0VFDulyAfA9wBcU0gVHVnqC5ghqXjggeitqtJ-1ZIZ1rmCgor42TXOteIQU/"
# urlimg <- "http://6iee.com/data/uploads/11/693547.jpg"
# urlimg <- "http://68.media.tumblr.com/21b140a3cdd69eeae22aee32642ca656/tumblr_o2o8h8nsmd1u8z9hho1_1280.jpg"

hchart(data, "areaspline", hcaes(x, y, group = "key"),
       color = c("#000000", "#333333")) %>% 
  hc_plotOptions(series = list(stacking = "normal")) %>% 
  hc_xAxis(type = "datetime", opposite = TRUE) %>% 
  hc_yAxis(reversed = TRUE) %>% 
  hc_add_theme(
    hc_theme(
      chart = list(
        divBackgroundImage = urlimg,
        backgroundColor = hex_to_rgba("white", 0.10)
        )
      ) 
  )
  
  
  

