# packags -----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(stringr)
library(jsonlite)
library(rvest)

# example -----------------------------------------------------------------
url <- "http://mtt-scl.data.pedalean.com/pedalean/mtt-gz/2017/04/20/00/20170420000001.json.gz"
data <- fromJSON(url)
names(data)
str(data, max.level = 2)

# download ----------------------------------------------------------------
urls <- read_html("http://mtt-scl.data.pedalean.com/pedalean/?prefix=mtt-gz/2017/05/12/06/&max-keys=10000000") %>% 
  html_nodes("key") %>% 
  html_text()


map(urls, function(u){ # u <- sample(urls, size = 1)
  
  message(u)
  
  file <- u %>% 
    basename() %>% 
    file.path("data", .)
  
  if(!file.exists(file)) {
    
    message("downlading")
    
    data <- fromJSON(url)
    
  } else {
    
    message("skipping")
    
  }
  
})

check <- map2(df_time$h, df_time$m, function(h, m){ # h <- "00"; m <- "23"
  
  message(rep("*-", 10))
  
  message(h, m)
  
  file <- str_c(Y, M, D, h, m, "01.json.gz", collapse = "")
  url <- file.path("http://mtt-scl.data.pedalean.com/pedalean/mtt-gz", Y, M, D, h,  file)
  
  message(url)
  
  if(httr::GET(url)$status != 404) {
    
    data <- jsonlite::fromJSON(url)
    
    message(data$fecha_consulta)
    
    return(1)
    
  } else {
    
    message("Errors", rep("!", 50))
    
    return(0)
    
  }
  
})
  

# 15% 0 85% 1
check %>% unlist %>% table %>% prop.table


names(data)
length(data$posiciones)

d <- read_delim(str_c(data$posiciones, collapse = "\n"), col_names = FALSE, delim = ";")

dpos <- data$posiciones %>% 
  map(str_split, ";") %>%
  map(unlist) %>% 
  map(t) %>% 
  map(as.matrix) %>% 
  reduce(rbind)

dpos3 <- as_data_frame(dpos)

count(dpos3, V2, sort = TRUE)


dpos2 <- map_df(1:4, function(x){ # x <- 2
  dpos[, 1:12 + 12*(x - 1)] %>% 
    as_data_frame()
})

dpos2

count(dpos2, V2, sort = TRUE)

dpos2 %>% 
  filter(V2 == "AA-0638")
