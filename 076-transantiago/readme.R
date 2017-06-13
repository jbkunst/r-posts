# packags -----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(stringr)
library(jsonlite)
library(rvest)

dir.create("data")
dir.create("data/raw")

# example -----------------------------------------------------------------
url <- "http://mtt-scl.data.pedalean.com/pedalean/mtt-gz/2017/04/20/00/20170420000001.json.gz"
data <- fromJSON(url)
names(data)
str(data, max.level = 2)

# download ----------------------------------------------------------------

"http://mtt-scl.data.pedalean.com/pedalean/?prefix=mtt-gz/2017/05/12/23/&max-keys=10000000"

urls <- 0:24 %>% 
  str_pad(2, pad = "0") %>% 
  file.path("http://mtt-scl.data.pedalean.com/pedalean/?prefix=mtt-gz", 2017, "05", "12", ., "&max-keys=10000000") %>% 
  map(read_html) %>% 
  map(html_nodes, "key") %>% 
  map(html_text) %>% 
  reduce(c)

length(urls)

map(urls, function(u){ # u <- sample(urls, size = 1)
  
  message(u)
  
  file <- u %>% 
    basename() %>% 
    file.path("data", "raw", .)
  
  if(!file.exists(file)) {
    
    message("downloading")
    
    saveRDS(fromJSON(url), file)
    
  } else {
    
    message("skipping")
    
  }
  
})


files <- dir("data/raw/", pattern = "^20170512", full.names = TRUE)

get_table_from_raw <- function(f) { # f <- sample(files, size = 1)
  
  # f <- "data/raw/20170512061401.json.gz"
  
  message(basename(f))
  
  data <- readRDS(f)
  
  dpos <- data$posiciones %>% 
    map(str_split, ";") %>%
    map(unlist) %>% 
    map(t) %>% 
    map(as.matrix) %>% 
    reduce(rbind)
  
  dpos2 <- map_df(1:4, function(x){ # x <- 2
    dpos[, 1:12 + 12*(x - 1)] %>% 
      as_data_frame()
  })
  
  dpos2
  
}

data <- map_df(files, get_table_from_raw)

