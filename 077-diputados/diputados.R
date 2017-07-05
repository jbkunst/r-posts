# setup -------------------------------------------------------------------
library(tidyverse)
library(rvest)
library(stringr)
library(janitor)

dir.create("data")
# file.remove(dir("data/", full.names = TRUE))

# data --------------------------------------------------------------------
url <- "https://www.camara.cl/trabajamos/sala_votacion_detalle.aspx?prmID="

ids <- 25886 - 0:1000

get_vote_data <- function(id = 25886) { # id <- sample(ids, size = 1)
  # id <- 25875
  
  message(id)
  
  fout <- sprintf("data/votacion_%s.rds", id)
  
  if(file.exists(fout))
    return(TRUE)

  html_detail <- read_html(paste0(url, id)) %>% 
    html_node("#detail")
  
  if(is.na(html_detail))
    return(TRUE)
  
  boletin <- html_detail %>% 
    html_node(".stress") %>% 
    html_nodes("h2") %>% 
    html_text() %>% 
    str_trim() %>% 
    ifelse(length(.) == 0, NA, .)
  
  boletin_desc <- html_detail %>% 
    html_node(".stress") %>% 
    html_nodes("h3") %>% 
    html_text() %>% 
    str_trim() %>% 
    ifelse(length(.) == 0, NA, .)
  
  meta_data <- html_detail %>% 
    html_node(".stress") %>% 
    html_nodes("p") %>% 
    html_text() %>% 
    str_trim() %>% 
    str_replace_all("\r|\n", "") %>% 
    str_replace_all("\\s+", " ") %>% 
    str_split_fixed(":", n = 2) %>% 
    tolower()
  
  dfmeta <- meta_data[,2] %>% 
    str_trim() %>% 
    t() %>% 
    as_data_frame() %>% 
    set_names(meta_data[,1]) %>% 
    mutate(boletin = boletin, boletin_desc = boletin_desc, id = id) %>% 
    select(id, boletin, everything()) %>% 
    clean_names()
  
  names(dfmeta) <- iconv(names(dfmeta), to = "ASCII//TRANSLIT")
  
  glimpse(dfmeta)
  
  vote_type <- c("A favor", "En contra", "Abstenc")
   
  dfvote <- map_df(vote_type, function(vt){ # vt <- sample(vote_type, size = 1)
      
    diputado_ids <- html_detail %>% 
      html_node(sprintf("div:contains('%s')", vt)) %>% 
      html_node("table") %>% 
      html_nodes("a") %>% 
      html_attr("href") %>% 
      str_extract("\\d+$")
    
    if(length(diputado_ids) > 0) {
      dout <- data_frame(id = id, vote = vt, diputado_id = diputado_ids)
    } else {
      dout <- data_frame()
    }
    
    dout
  })
  
  saveRDS(list(dfmeta, dfvote), file = fout)
  
}

map(sample(ids), get_vote_data)



#  consolidate ------------------------------------------------------------
files <- dir("data/", full.names = TRUE, pattern = "votacion_")

data <- map(files, readRDS)

data_meta <- map_df(data, 1)
data_vote <- map_df(data, 2)

