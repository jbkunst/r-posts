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
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

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
  message(x)
  # x <- sample(url_detail, 1)
  # x <- "http://bulbapedia.bulbagarden.net/wiki/Volcanion_(Pok%C3%A9mon)"
  x %>% 
    read_html() %>% 
    html_nodes("img") %>% 
    html_attr("src") %>% 
    {.[str_detect(.,"250")]} %>% 
    {.[str_detect(.,"http://cdn.bulbagarden.net/upload/thumb") ]} %>% 
    .[1]
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

dfpoke3 <- map_df(dfpoke1$api_url, function(x){
  message(x)
  # x <- sample(dfpoke1$api_url, size = 1); x <- "api/v1/pokemon/718/"
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
             type_2 = ifelse(length(l$types) > 1, l$types[[2]]$name, NA),
             url_image_api = ifelse(length(l$sprites) > 0,
                                    sprintf("http://pokeapi.co/media/img/%s.png", pkdx_id)  , NA))
  
})

dfpokecols <- map_df(na.omit(unique(c(dfpoke3$type_1, dfpoke3$type_2))), function(t){
  # t <- "bug"
  col <- "http://pokemon-uranium.wikia.com/wiki/Template:%s_color" %>% 
    sprintf(t) %>%
    read_html() %>% 
    html_nodes("span > b") %>% 
    html_text()
  data_frame(type = t, color = paste0("#", col))
})

getpcol <- function(col1, col2, n = 10, p = 0.3) {
  # col1 <- "#FFFF00"; col2 <- "#0000FF"
  colorRampPalette(c(col1, col2))(n)[round(n*p)]
}

dfpoke <- dfpoke1 %>% 
  inner_join(dfpoke3, by = "api_url") %>%
  inner_join(dfpoke2, by = "name") %>% 
  left_join(dfpokecols %>% rename(type_1 = type, color_t1 = color), by = "type_1") %>% 
  left_join(dfpokecols %>% rename(type_2 = type, color_t2 = color), by = "type_2") %>%
  mutate(color_t2 = ifelse(is.na(color_t2), color_t1, color_t2),
         color_tp = unlist(map2(.$color_t1, .$color_t2, getpcol))) %>% 
  arrange(pkdx_id)


# save(dfpoke, file = "dfpoke.RData")
# rm(list = ls())
# load("dfpoke.RData")

##' ## Treemap ####
library("highcharter")
library("treemap")
dftm <- dfpoke %>% 
  mutate(type_2 = ifelse(is.na(type_2), paste("only", type_1), type_2),
         type_1 = paste("Main", type_1)) %>% 
  group_by(type_1, type_2) %>%
  summarise(n = n()) %>% 
  ungroup()
  
tm <- treemap(dftm, index = c("type_1", "type_2"), vSize = "n", vColor = "type_1")
tm$tm

highchart() %>% 
  hc_add_series_treemap(tm, allowDrillToNode = TRUE,
                        layoutAlgorithm = "squarified" )

##' ## t-SNE ####
library("tsne")
library("ggplot2")

dfpokenum <- dfpoke %>% 
  select(-name, -pkdx_id, -id, -pokemon,
         -total, -average, -contains("url"),
         -color_t1, -color_t2, -color_tp,
         -weight, -height) %>% 
  map(function(x){
    ifelse(is.na(x), "NA", x)
  }) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  model.matrix(~., data = .) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  .[-1]

set.seed(124)
tsne_poke <- tsne(dfpokenum, max_iter = 500)

dfpoke <- dfpoke %>% 
  mutate(x = tsne_poke[, 1],
         y = tsne_poke[, 2])

ggplot(dfpoke) + 
  geom_point(aes(x, y, color = type_1), size = 4, alpha = 0.5) +
  scale_color_manual("Type", values = unique(setNames(dfpoke$color_t1, dfpoke$type_1))) + 
  theme_minimal() +
  theme(legend.position = "bottom")


dspoke <- dfpoke %>% 
  select(pokemon, type_1, type_2, weight, height,
         attack, defense, special_attack, special_defense,
         url_image = url_image_bp, url_icon = url_icon_bp, color = color_t1, x, y) %>% 
  list.parse3() %>% 
  map(function(x){
    x$marker$symbol <- sprintf("url(%s)", x$url_icon)
    x$marker$radius <- 2
    x$url_icon  <- NULL
    x
  })

nms <- setdiff(names(dspoke[[1]]), c("marker", "url_image", "url_icon", "color", "x", "y"))
htmltbl <- map_chr(nms, function(nm){
  sprintf("<tr><th>%s</th><td style='min-width:100px'>{point.%s}</td></tr>",
          str_replace_all(str_to_title(nm), "_", " "),
          nm)
}) %>% paste(collapse = "")

thm <- hc_theme_merge(
  hc_theme_null(),
  hc_theme(
    chart = list(
      backgroundColor = "transparent",
      # divBackgroundImage = "https://coinarcade.files.wordpress.com/2013/08/006-charizard.jpg" # mewtwo
      # divBackgroundImage = "http://orig04.deviantart.net/e1d6/f/2015/044/1/a/lapras_from_pokemon___minimalist_by_matsumayu-d8b3ame.png" # lapras
      # divBackgroundImage = "http://orig00.deviantart.net/719d/f/2013/270/e/b/gengar_2_by_paulosaopaulino-d6o86h4.png" # boo
      divBackgroundImage = "http://www.wallpaperup.com/uploads/wallpapers/2014/04/29/345767/6013e88f504983dcab867b92335c4954.jpg"
      # divBackgroundImage = "http://images2.alphacoders.com/127/127692.jpg"
    )
  )
)

highchart() %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_xAxis(minRange = diff(range(dfpoke$x))/2) %>% 
  hc_yAxis(minRange = diff(range(dfpoke$y))/2) %>% 
  hc_add_series(data = dspoke,
                type = "scatter",
                states = list(hover = list(halo = list(
                  size  = 100,
                  attributes = list(
                    opacity = 1)
                )))) %>% 
  hc_plotOptions(series = list()) %>%  
  hc_tooltip(
    useHTML = TRUE,
    borderRadius = 0,
    borderWidth = 10,
    # positioner = JS("function () { return { x: 0, y: 0 }; }"),
    headerFormat = "<table>",
    pointFormat = paste(htmltbl, "<img src='{point.url_image}' width='125px' height='125px'>"),
    footerFormat = "</table>"
  ) %>% 
  hc_add_theme(thm)
