# packags -----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(stringr)
library(jsonlite)
library(rvest)
library(lubridate)
library(data.table)


dir.create("data")
dir.create("data/raw")
dir.create("data/tsv")

# example -----------------------------------------------------------------
url <- "http://mtt-scl.data.pedalean.com/pedalean/mtt-gz/2017/04/20/00/20170420000001.json.gz"
data <- fromJSON(url)
names(data)
str(data, max.level = 2)

# download ----------------------------------------------------------------
"http://mtt-scl.data.pedalean.com/pedalean/?prefix=mtt-gz/2017/05/12/23/&max-keys=10000000"

get_urls_date <- function(date = ymd("20170507")) {
  
  urls <- 0:24 %>% 
    str_pad(2, pad = "0") %>% 
    file.path(
      "http://mtt-scl.data.pedalean.com/pedalean/?prefix=mtt-gz",
      format(date, "%Y"), 
      format(date, "%m"),
      format(date, "%d"),
      ., 
      "&max-keys=10000000") %>% 
    map(read_html) %>% 
    map(html_nodes, "key") %>% 
    map(html_text) %>% 
    reduce(c)
  
  urls
  
}

download_url <- function(u) {

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
    
}

library(magrittr)

write_to_tsv <- function(f) { # f <- "mtt-gz/2017/05/12/18/20170512180401.json.gz"
  
  message(basename(f))
  
  data <- readRDS(file.path("data", "raw", basename(f)))
  
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
  
  basename(f) %>% 
    str_replace(".json.gz", ".tsv") %>% 
    file.path("data", "tsv", .) %>% 
    fwrite(dpos2, .)

}


auxfile <- tempfile(fileext = ".tsv")

message(auxfile)

files <- dir("data/raw/", pattern = "^20170512", full.names = TRUE)


files %>% 
  map(function(f){
    
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
    
    # basename(f) %>% 
    #   str_replace(".json.gz", ".tsv") %>% 
    #   file.path("data", "tsv", .) %>% 
    
    fwrite(dpos2, auxfile, append = file.exists(auxfile))
    
  })


ymd("20170512") %>% 
  get_urls_date() %T>% 
  map(download_url) %>% 
  map(write_to_tsv)




