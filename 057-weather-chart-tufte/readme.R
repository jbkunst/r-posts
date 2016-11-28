#' ---
#' title: "Wheather chart a la Tufte"
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

#'
library(tidyverse)
library(highcharter)
library(lubridate)
library(stringr)
library(forcats)

#' ## Data
#' 
#' Lorem lorem
#' 
url_base <- "http://graphics8.nytimes.com/newsgraphics/2016/01/01/weather/assets"
file <- "new-york_ny.csv" # "san-francisco_ca.csv"
url_file <- file.path(url_base, file)

data <- read_csv(url_file)
data

data <- mutate(data, dt = datetime_to_timestamp(date))

options(highcharter.theme = hc_theme_smpl())


#' ## Setup
#' 
#' Lorem lorem setup
#' 
hc <- highchart() %>%
  # axis setup
  hc_xAxis(type = "datetime",
           dateTimeLabelFormats = list(month = "%B"),
           showLastLabel = FALSE) %>% 
  # setting tooltip
  hc_tooltip(shared = TRUE,
             seHTML = TRUE,
             headerFormat = as.character(tags$small("{point.x: %b %d}", tags$br()))) %>% 
  hc_plotOptions(series = list(borderWidth = 0, pointWidth = 4))

hc

#' ## Adding data
#' 
#' The traditional way is 1 by 1 the series
#' 
#' 
#+ eval=FALSE
hc %>% 
  hc_add_series(data, type = "columnrange", hcaes(dt, low = temp_rec_min, high = temp_rec_max),
                name = "Record", color = "#ECEBE3") %>% 
  hc_add_series(data, type = "columnrange", hcaes(dt, low = temp_avg_min, high = temp_avg_max),
                name = "Normal", color = "#C8B8B9") %>% 
  hc_add_series(data, type = "columnrange", hcaes(dt, low = temp_min, high = temp_max),
                name = "Observed", color = "#A90048") 

#' 
#' But we can get some fun wrangling the data
#' 
#' 
datagather <- data %>% 
select(dt, starts_with("temp")) %>% 
  select(-temp_rec_high, -temp_rec_low) %>% 
  rename(temp_actual_max = temp_max,
         temp_actual_min = temp_min) %>% 
  gather(key, value, -dt) %>% 
  mutate(key = str_replace(key, "temp_", "")) 

datagather

dataspread <- datagather %>% 
  separate(key, c("serie", "type"), sep = "_") %>% 
  spread(type, value)

dataspread

#' Finaly some fixes
#' 

data2 <- dataspread %>% 
  mutate(serie = factor(serie, levels = c("rec", "avg", "actual")),
         serie = fct_recode(serie, Record = "rec", Normal = "avg", Observed = "actual"))

data2

#' So, why thiz codez? Just for get a tidy data for easy charting.

hc <- hc %>% 
  hc_add_series(data2, type = "columnrange",
                hcaes(dt, low = min, high = max, group = serie),
                color = c("#ECEBE3", "#C8B8B9", "#A90048")) 

hc

#' ## Adding other data in other axis
#' 
#' First create a list with 2 axis and using the  `create_yaxis` helper
axis <- create_yaxis(
  naxis = 2,
  heights = c(3,1),
  turnopposite = FALSE,
  showLastLabel = FALSE,
  startOnTick = FALSE)

#' Manually add titles (I know this can be more elegant)
# axis[[1]]$title <- list(text = "Temperature")
# axis[[2]]$title <- list(text = "Precipitation")
# 
# hc <- hc_yAxis_multiples(hc, axis)  
# 
# hc

#' Te 2 axis are ready, now just add the data. Here we will add 12 series 
#' -one for each month- but we want to asociate 1 legend for all these 12 
#' series, so we need to use `id` and `linkedTo` parameters and obviously
#' add this data to the second axis.

# hc <- hc %>% 
#   hc_add_series(data, type = "area", hcaes(dt, precip_value, group = month),
#                 name = "Precipitation", color = "skyblue", yAxis = 1, 
#                 id = c("p", rep(NA, 11)), linkedTo = c(NA, rep("p", 11)))
# 
# hc

#' ## Some final touches
#' 
#' The records and the title and some credit to the serious touch
#' 
#' ### Title
#' 
#' Here we will extract the title from the file name, this will usefull if
#' we want to make it autoamtically if we do some shiny app for example
city <- file %>%
  str_extract(".*_") %>%
  str_replace_all("_", "") %>%
  str_replace_all("-", " ") %>%
  str_to_title()

state <- file %>%
  str_extract("_.*") %>%
  str_replace_all("_|\\.csv", "") %>%
  str_to_upper()

title <- paste0(city, ", ", state)

hc <- hc %>%
  hc_title(text = title)

#' ### Records

annotations <- data %>%
  select(dt, temp_rec_high, temp_rec_low) %>% 
  filter(temp_rec_high != "NULL" | temp_rec_low != "NULL") %>% 
  dmap_if(is.character, str_extract, "\\d+") %>% 
  dmap_if(is.character, as.numeric) %>% 
  gather(type, value, -dt) %>% 
  filter(!is.na(value)) %>% 
  mutate(type = str_replace(type, "temp_rec_", ""),
         xValue = dt,
         yValue = value)
  

annotations$title <- map3(annotations$type, annotations$value, annotations$type, function(x, y, z){
  
  sign <- ifelse(z == "high", -1, 1)
  list(text = paste(x, y), style = list(fontSize = 10),  y = 40 * sign)

})

annotations$shape <- map(annotations$type, function(t){
  sign <- ifelse(t == "high", -1, 1)
  sign <- 1
  list(type = "path", params = list(d = list('M', 10, 0, 'V', 30 * sign)))
})

hc %>% 
  hc_add_annotations(annotations)



#' ## Volia
hc
