#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message=FALSE, warning=FALSE)

#'
library("dplyr")
library("httr")
library("rvest")
library("magrittr")
library("purrr")
library("stringr")


dfpoke1 <- "http://pokeapi.co/api/v1/pokedex/1/" %>% 
  GET() %>% 
  content() %>% 
  .$pokemon %>% 
  map_df(function(x){
    data_frame(name = x$name,
               api_url = x$resource_uri)
    }) 

url_bulbapedia_list <- "http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_base_stats_(Generation_VI-present)" 

dfpoke2 <- url_bulbapedia_list %>% 
  read_html(encoding = "UTF-8") %>% 
  html_node("table.sortable") %>% 
  html_table() %>% 
  setNames(c("id", "icon", "pokemon", "hp", "attack",
             "defense", "special_attack", "special_defense",
             "speed", "total", "average")) %>% 
  select_("-icon") %>% 
  tbl_df() %>% 
  mutate(name = str_to_lower(pokemon)) 

url_icon <-  url_bulbapedia_list %>% 
  read_html() %>%
  html_nodes("table.sortable img") %>% 
  html_attr("src")

url_detail <- url_bulbapedia_list %>% 
  read_html() %>%
  html_nodes("table.sortable span a") %>% 
  html_attr("href") %>% 
  paste0("http://bulbapedia.bulbagarden.net", .)

url_image <- map_chr(url_detail, function(x){
  # x <- sample(url_detail, 1)
  x %>% 
    read_html() %>% 
    html_nodes("img") %>% 
    .[[3]] %>% 
    html_attr("src")
})

dfpoke2 <- dfpoke2 %>% 
  mutate(url_icon_bp = url_icon,
         url_detail_bp = url_detail,
         url_image_bp = url_image)



dfpoke2 <- dfpoke2 %>% 
  mutate(name = ifelse(str_detect(name, " \\(mega \\w+\\)$"),
                       str_replace(name, " \\(mega \\w+\\)$", "-mega"),
                       name),
         name = ifelse(str_detect(name, " \\(\\w+ (forme|size|cloack|rotom|kyurem|mode|cloak)\\)$"),
                       name %>% str_replace_all(" \\(| (forme|size|cloack|rotom|kyurem|mode|cloak)\\)", " ") %>% str_trim %>% str_replace_all("\\s+", "-"),
                       name),
         name = ifelse(str_detect(name, "\\w+ \\(mega \\w+ (y|x)\\)"),
                       name %>% str_replace_all(" \\w+ | \\(", "-") %>% str_replace("\\)", ""),
                       name),
         name = str_replace(name, "-normal", ""),
         name = str_replace(name, "farfetch'd", "farfetchd"),
         name = str_replace(name, "mime jr.", "mime-jr"),
         name = str_replace(name, "mr. mime", "mr-mime"),
         name = str_replace(name, "aegislash-shield", "aegislash"),
         name = str_replace(name, "basculin", "basculin-red-striped"),
         name = str_replace(name, "keldeo", "keldeo-ordinary"),
         name = str_replace(name, "meowstic", "meowstic-male"),
         name = ifelse(str_detect(name, "nidoran"),
                       ifelse(str_extract(id, "\\d+") == "032",
                              "nidoran-m", "nidoran-f"), name),
         name = ifelse(id == "669", "flabebe", name),
         name = ifelse(name == "deoxys", "deoxys-normal", name))


t0 <- Sys.time()
dfpoke3 <- map_df(dfpoke1$api_url, function(x){
  # x <- sample(dfpoke1$api_url, size = 1); x <- "api/v1/pokemon/10002/"
  l <- file.path("http://pokeapi.co/", x) %>% 
    GET() %>% 
    content()
  # l$moves <- NULL; l$descriptions <- NULL; l$abilities <- NULL
  l$name
  data_frame(api_url = x,
             pkdx_id = l$pkdx_id,
             weight = l$weight,
             height = l$height,exp = l$exp,
             ntypes = length(l$types),
             egg_group_1 =  ifelse(length(l$egg_groups) > 0, l$egg_groups[[1]]$name, NA),
             egg_group_2 = ifelse(length(l$egg_groups) > 1, l$egg_groups[[2]]$name, NA),
             type_1 = ifelse(length(l$types) > 0, l$types[[1]]$name, NA),
             type_2 = ifelse(length(l$types) > 1, l$types[[2]]$name, NA))
  
})

tf <- Sys.time() - t0
tf

dfpoke <- dfpoke1 %>% 
  inner_join(dfpoke3, by = "api_url") %>%
  inner_join(dfpoke2, by = "name")


# readr::write_csv(dfpoke, "dfpoke.csv")
# rm(list = ls())
dfpoke <- readr::read_csv("dfpoke.csv")

dfpv <- dfpoke %>% 
  select(-name, -pkdx_id, -id, -pokemon,
         -total, -average, -contains("url"))

dfpv[is.na(dfpv)] <- "-"
