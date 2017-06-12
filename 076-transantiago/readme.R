# packags -----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(stringr)

# example -----------------------------------------------------------------
url <- "http://mtt-scl.data.pedalean.com/pedalean/mtt-gz/2017/04/20/00/20170420000001.json.gz"
data <- jsonlite::fromJSON(url)
names(data)

# download ----------------------------------------------------------------
df_time <- expand.grid(h = 0:23, m = 0:59) %>% 
  tbl_df() %>% 
  mutate_all(str_pad, width = 2, side = "left", pad = "0") %>% 
  arrange(h, m)

Y <- "2017"
M <- str_pad( 5, 2, pad = "0")
D <- str_pad(12, 2, pad = "0")

message(Y, M, D)

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
