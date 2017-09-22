# setup -------------------------------------------------------------------
library(tidyverse)
library(rvest)
library(stringr)
library(janitor)

dir.create("data")
# file.remove(dir("data/", full.names = TRUE))


# helpers -----------------------------------------------------------------
str_clean_spaces <- function(x) {
  x %>% 
    str_replace_all("\\s+", " ") %>% 
    str_replace_all("\r|\n", "") %>% 
    str_trim()
}


# votaciones --------------------------------------------------------------
url_vot <- "https://www.camara.cl/trabajamos/sala_votacion_detalle.aspx?prmID="

get_vote_data <- function(id = 25886) { # id <- sample(ids, size = 1)
  # id <- 7034
  message("votacion :", id)
  
  fout <- sprintf("data/votacion_%s.rds", id)
  
  if(file.exists(fout))
    return(TRUE)

  html_detail <- read_html(paste0(url_vot, id)) %>% 
    html_node("#detail")
  
  if(length(html_detail) == 0) {
    
    saveRDS(list(data_frame(), data_frame()), file = fout)
    
    return(TRUE)
  }
    
  
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
    mutate(boletin = boletin, boletin_desc = boletin_desc, votacion_id = id) %>% 
    select(votacion_id
           , boletin, everything()) %>% 
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
      dout <- data_frame(votacion_id = id, vote = vt, diputado_id = diputado_ids)
    } else {
      dout <- data_frame()
    }
    
    dout
  })
  
  saveRDS(list(dfmeta, dfvote), file = fout)
  
}


# ids <- 26000:1
ids <- 1282:26000

map(sample(ids), get_vote_data)

files <- dir("data/", full.names = TRUE, pattern = "votacion_")

data <- map(files, readRDS)
head(data)

data_meta <- map_df(data, 1)
data_meta
tail(data_meta)

data_vote <- map_df(data, 2)

tail(count(data_vote, votacion_id, sort = TRUE))


# diputados ---------------------------------------------------------------
url_dip <- "https://www.camara.cl/camara/diputado_detalle.aspx?prmID="

get_dip_data <- function(id = 972){
  # id <- 23423423423
  message("diputado :", id)
  
  html_ficha <- read_html(paste0(url_dip, id)) %>% 
    html_node("#ficha")
  
  if(length(html_ficha) == 0) {
    return(data_frame())
  }
  
  dout <- data_frame(
    diputado_id = id,
    nombre = html_ficha %>% html_node("h3") %>% html_text() %>% str_clean_spaces(),
    comite = html_ficha %>%
      html_nodes(".summary") %>% 
      { .[[3]] } %>% 
      html_node("p") %>% 
      html_text() %>% 
      str_clean_spaces(),
    img_url = html_ficha %>% html_node(".imgSet > img") %>% html_attr("src"),
    fecha_namcimiento = html_ficha %>% html_node(".birthDate") %>% html_node("p") %>% html_text() %>% str_clean_spaces(),
    profesion = html_ficha %>% html_node(".profession") %>% html_node("p") %>% html_text() %>% str_clean_spaces()
  )
  
  dout
    
}

# ids <- 1:1500
ids <- c(177, 800:1007)

diputados1 <- map_df(ids, get_dip_data)
diputados1


diputados2 <- read_html("https://www.camara.cl/camara/diputados.aspx") %>% 
  html_nodes(".alturaDiputado") %>% 
  map_df(function(e){
    # e <- dip[[1]]
    
    data <- e %>%
      html_nodes("li") %>%
      html_text() %>% 
      str_replace(".*:", "") %>% 
      str_trim()
    
    id <- e %>% 
      html_node("h4") %>% 
      html_node("a") %>% 
      html_attr("href") %>% 
      str_extract("\\d+$") %>% 
      as.numeric()
    
    data_frame(
      diputado_id = id,
      region = data[1],
      distrito = data[2],
      partido = data[3]
    )
   
    
  })


diputados <- full_join(diputados1, diputados2)
glimpse(diputados)

count(diputados, partido, sort = TRUE)
count(diputados, partido, comite, sort = TRUE)


data_vote %>% 
  count(diputado_id)
data_meta
diputados


# filtering ---------------------------------------------------------------
data_vote <- mutate(data_vote, diputado_id = as.numeric(diputado_id))

primera_votacion_ultimo_periodo <- data_vote %>% 
  semi_join(diputados) %>% 
  filter(diputado_id== 968) %>% 
  count(votacion_id, sort = TRUE) %>% 
  left_join(data_meta) %>%
  arrange(votacion_id) %>% 
  pull(votacion_id) %>% 
  first()
  
primera_votacion_ultimo_periodo




data_votacion_detalle <- data_vote %>% 
  filter(votacion_id >= primera_votacion_ultimo_periodo)

# data_diputados
data_diputados <- diputados

data_diputados <- data_diputados %>% 
  mutate(nombre = str_replace(nombre, "\\w+ ", ""),
         profesion = str_replace(profesion, "\\.$", ""),
         distrito = str_replace(distrito, "N°", "")) %>% 
  glimpse()

# data_votacion_meta
data_votacion_meta <- data_meta %>% 
  filter(votacion_id >= primera_votacion_ultimo_periodo)

glimpse(data_votacion_meta)
data_votacion_meta <- data_votacion_meta %>% 
  separate(fecha, c("dia", "mes", "ano_hora"), "\\s+de\\s+") %>% 
  separate(ano_hora, c("ano", "hora"), "\\s+") %>% 
  mutate(boletin = str_replace(boletin, "Boletín N° ", "")) %>% 
  glimpse()


# export ------------------------------------------------------------------
dir.create("csv")
write_csv(data_votacion_detalle, "csv/votacion_detalle.csv")
write_csv(data_diputados, "csv/diputados.csv")
write_csv(data_votacion_meta, "csv/votacion_metadata.csv")


