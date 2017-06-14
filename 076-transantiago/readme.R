# packages ----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(stringr)
library(jsonlite)
library(rvest)
library(lubridate)
library(data.table)
library(magrittr)

dir.create("data")
dir.create("data/raw-rds")
dir.create("data/tbl-rds")
dir.create("data/tbl-rds-clean")

# example -----------------------------------------------------------------
# url <- "http://mtt-scl.data.pedalean.com/pedalean/mtt-gz/2017/04/20/00/20170420000001.json.gz"
# data <- fromJSON(url)
# names(data)
# str(data, max.level = 2)

BASE_URL <- "http://mtt-scl.data.pedalean.com/pedalean"

# functions ---------------------------------------------------------------
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

download_url <- function(url) { # url <- sample(urls, size = 1)

  message(url)
  
  file <- url %>% 
    basename() %>% 
    str_replace(".json.gz", ".rds") %>%
    file.path("data/raw-rds", .)
  
  if(file.exists(file)) {
    message("skipping")
    return(TRUE)
  }
  
  message("downloading")
  
  url %>% 
    file.path(BASE_URL, .) %>% 
    fromJSON() %>% 
    saveRDS(file)
  
}

raw_to_dfrds <- function(f) { # f <- sample(files, size = 1)
  
  message(f)

  file <- f %>% 
    basename() %>% 
    str_sub(0, 12) %>% 
    file.path("data/tbl-rds", .) %>% 
    paste0(".rds")
  
  if(file.exists(file)) {
    message("skipping")
    return(TRUE)
  }
  
  message("processing raw data")
  
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
  
  message("writing ", scales::comma(nrow(dpos)), " rows from ", basename(f), " to ", file)
  
  saveRDS(dpos2, file)
    
}

clean_rds <- function(f) { # f <- sample(files, size = 1)
  
  message(f)
  
  file <- str_replace(f, "tbl-rds", "tbl-rds-clean")
  
  if(file.exists(file)) {
    message("skipping")
    return(TRUE)
  }
  
  message("cleaning raw data")
  
  data <- readRDS(f)
  
  # glimpse(data)
  names(data) <- c("fecha_hora", "patente", "lat", "lon", "velocidad",
                   "direccion", "op", "nombre", "sentido", "consola_ruta",
                   "sinoptico_ruta", "fecha_hora_insercion")
  
  # glimpse(data)
  
  count(data, fecha_hora, patente)
  
  datac <- data %>% 
    select(fecha_hora, patente, lat, lon, velocidad, direccion, nombre, sentido,
           fecha_hora_insercion) %>% 
    mutate_at(vars(lat, lon, velocidad, direccion), as.numeric) %>% 
    # separate(fecha_hora, c("fecha", "hora"), sep = " ") %>% 
    # separate(hora, c("hora", "minuto", "segundo"), sep = ":") %>% 
    # mutate(fecha = dmy(fecha), hora = hms(hora)) %>% 
    mutate(
      fecha_hora = as.POSIXct(fecha_hora, format = "%d-%m-%Y %H:%M:%S"),
      fecha_hora_insercion = as.POSIXct(fecha_hora_insercion, format = "%d-%m-%Y %H:%M:%S")
      ) %>% 
    # filter(!is.na(fecha)) %>%
    filter(!is.na(fecha_hora)) 
  
  # arrange(data, patente, fecha_hora)
  # arrange(datac, patente, fecha_hora)
  # 
  # distinct(data)
  # count(data, fecha_hora, patente)
  # count(datac, fecha, hora, minuto, segundo, patente)
  # 
  # data
  # 
  # data %>%  filter(patente == "CJRS-65")
  # datac %>%  filter(patente == "CJRS-65")
  
  saveRDS(datac, file)
 
  
}

get_day_data <- function(date = ymd("20170507")) {
 
  urls <- get_urls_date(date)
  
  map(sample(urls), download_url)
  
  files <- dir("data/raw-rds/", pattern = paste0("^", format(date, "%Y%m%d")), full.names = TRUE)
  
  map(sample(files), raw_to_dfrds)
  
  files <- dir("data/tbl-rds/", pattern = paste0("^", format(date, "%Y%m%d")), full.names = TRUE)
  
  map_df(files, clean_rds)
  
}

# download ----------------------------------------------------------------
get_day_data()

identical(
  readRDS("data/raw-rds/20170507044601.rds"),
  readRDS("data/raw-rds/20170507062701.rds")
)

identical(
  readRDS("data/tbl-rds/201705070516.rds"),
  readRDS("data/tbl-rds/201705071455.rds")
)

