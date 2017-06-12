library(tidyverse)
library(stringr)

url <- "http://mtt-scl.data.pedalean.com/pedalean/mtt-gz/2017/04/20/00/20170420000001.json.gz"

data <- jsonlite::fromJSON(url)

names(data)
length(data$posiciones)

data$posiciones %>% 
  head() %>% 
  map(print) %>% 
  map(str_split, ";") %>%
  map(unlist) %>% 
  map(length)
