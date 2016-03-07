#' ---
#' title: "pkmn visualize 'em all!"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#  setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

library("dplyr")
library("readr")
library("rvest")
library("purrr")
library("stringr")
library("tidyr")
library("highcharter")
library("tsne")
library("ggplot2")
library("htmltools")

#'
#' Time ago, when I was a younger man I know pokemon I konw the 150 pokemon then I 
#' And more than 10 year there are over 700 with new types new, new regions, etc. So
#' to know the status of all these monster I download the data and make some
#' chart to see 
#' 

#' 
#' ## Data
#' 
#' There is a pokemon api http://pokeapi.co/. But we want all the pokemon data once so
#' we can go to the repository I found the raw data https://github.com/phalt/pokeapi/tree/master/data/v2/csv .
#' We'll need other type of data like type's colors, icon images. This data we founded here 
#' http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_base_stats_(Generation_VI-present) and
#' http://pokemon-uranium.wikia.com/wiki/Template:fire_color.
#' 
#' Now to the script
#' 

path <- function(x) paste0("https://raw.githubusercontent.com/phalt/pokeapi/master/data/v2/csv/", x)

dfpkmn <- read_csv(path("pokemon.csv")) %>% 
  select(-order, -is_default) %>% 
  rename(pokemon = identifier)

dfstat <- read_csv(path("stats.csv")) %>% 
  rename(stat_id = id) %>% 
  right_join(read_csv(path("pokemon_stats.csv")),
             by = "stat_id") %>% 
  mutate(identifier = str_replace(identifier, "-", "_")) %>% 
  select(pokemon_id, identifier, base_stat) %>% 
  spread(identifier, base_stat) %>% 
  rename(id = pokemon_id)

dftype <- read_csv(path("types.csv")) %>% 
  rename(type_id = id) %>% 
  right_join(read_csv(path("pokemon_types.csv")), by = "type_id") %>% 
  select(pokemon_id, identifier, slot) %>% 
  mutate(slot = paste0("type_", slot)) %>% 
  spread(slot, identifier) %>% 
  rename(id = pokemon_id)

dfegg <- read_csv(path("egg_groups.csv")) %>% 
  rename(egg_group_id = id) %>% 
  right_join(read_csv(path("pokemon_egg_groups.csv")), by = "egg_group_id") %>% 
  group_by(species_id) %>% 
  mutate(ranking = row_number(),
         ranking = paste0("egg_group_", ranking)) %>% 
  select(species_id, ranking, identifier) %>% 
  spread(ranking, identifier) 

dfimg <- "https://github.com/phalt/pokeapi/tree/master/data/Pokemon_XY_Sprites" %>% 
  read_html() %>% 
  html_nodes("tr.js-navigation-item > .content > .css-truncate a") %>% 
  map_df(function(x){
    url <- x %>% html_attr("href")
    data_frame(
      id = str_extract(basename(url), "\\d+"),
      url_image = basename(url)
    )
  }) %>%
  mutate(id = as.numeric(id))

url_bulbapedia_list <- "http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_base_stats_(Generation_VI-present)" 

id <- url_bulbapedia_list %>% 
  read_html(encoding = "UTF-8") %>% 
  html_node("table.sortable") %>% 
  html_table() %>% 
  .[[1]] %>% 
  as.numeric()

url_icon <-  url_bulbapedia_list %>% 
  read_html() %>%
  html_nodes("table.sortable img") %>% 
  html_attr("src")

dficon <- data_frame(id, url_icon) %>% 
  filter(!is.na(id)) %>% 
  distinct(id)

dfcolor <- map_df(na.omit(unique(c(dftype$type_1, dftype$type_2))), function(t){
  # t <- "bug"
  col <- "http://pokemon-uranium.wikia.com/wiki/Template:%s_color" %>% 
    sprintf(t) %>%
    read_html() %>% 
    html_nodes("span > b") %>% 
    html_text()
  data_frame(type = t, color = paste0("#", col))
})

dfcolorf <- expand.grid(color_1 = dfcolor$color, color_2 = dfcolor$color,
                        stringsAsFactors = FALSE) %>% 
  tbl_df() %>% 
  group_by(color_1, color_2) %>% 
  do({
      n = 100;p = 0.25
      data_frame(color_f = colorRampPalette(c(.$color_1, .$color_2))(n)[round(n*p)])
    })

# THE join
df <- dfpkmn %>% 
  left_join(dftype, by = "id") %>% 
  left_join(dfstat, by = "id") %>% 
  left_join(dfcolor %>% rename(type_1 = type, color_1 = color), by = "type_1") %>% 
  left_join(dfcolor %>% rename(type_2 = type, color_2 = color), by = "type_2") %>% 
  left_join(dfcolorf, by =  c("color_1", "color_2")) %>% 
  left_join(dfegg, by = "species_id") %>% 
  left_join(dfimg, by = "id") %>% 
  left_join(dficon, by = "id")

#'
#' Finally we remove the pokemon with no images (like the mega ones).
#'
df <- df %>% 
  mutate(color_f = ifelse(is.na(color_f), color_1, color_f)) %>% 
  filter(!is.na(url_image)) 

str(df)

head(df)

#' ## *bar chart* I choose you 

dstype <- df %>% 
  count(type_1, color_1) %>% 
  ungroup() %>% 
  arrange(desc(n)) %>% 
  mutate(x = row_number()) %>% 
  rename(
    name = type_1,
    color = color_1,
    y = n
  ) %>% 
  select(y, name, color) %>% 
  list.parse3()
  
hcb <- highchart() %>% 
  hc_xAxis(categories = unlist(pluck(dstype, i = 2))) %>% 
  hc_yAxis(title = NULL) %>% 
  hc_add_series(data = dstype, type = "bar", showInLegend = FALSE,
                name = "Number of species")

hcb

#'
#'  ## Oh! The *bar chat* has evolved into a *treemap*
#'  

#+fig.keep='none'
dftm <- df %>% 
  mutate(type_2 = ifelse(is.na(type_2), paste("only", type_1), type_2),
         type_1 = type_1) %>% 
  group_by(type_1, type_2) %>%
  summarise(n = n()) %>% 
  ungroup()

set.seed(3514)

tm <- treemap::treemap(dftm, index = c("type_1", "type_2"), vSize = "n", vColor = "type_1")

tm$tm <- tm$tm %>%
  tbl_df() %>% 
  left_join(df %>% select(type_1, type_2, color_f) %>% distinct(), by = c("type_1", "type_2")) %>%
  left_join(df %>% select(type_1, color_1) %>% distinct(), by = c("type_1")) %>% 
  mutate(type_1 = paste0("Main ", type_1),
         color = ifelse(is.na(color_f), color_1, color_f))

hctm <- highchart() %>% 
  hc_add_series_treemap(tm, allowDrillToNode = TRUE,
                        layoutAlgorithm = "squarified")

hctm

#+echo=FALSE
saveRDS(hctmpkmn <- hctm, file = "~/hctmpkmn.rds", compress = "xz")


#'
#' ## t-SNE
#' 
#' 
dfnum <- df %>% 
  select(type_1, type_2, weight, height, base_experience, attack,
         defense, hp, special_attack, special_defense, speed,
         egg_group_1, egg_group_2) %>% 
  map(function(x){
    ifelse(is.na(x), "NA", x)
  }) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  model.matrix(~., data = .) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  .[-1]

set.seed(13242)

tsne_poke <- tsne(dfnum, max_iter = 500)

df <- df %>% 
  mutate(x = tsne_poke[, 1],
         y = tsne_poke[, 2])

ggplot(df) + 
  geom_point(aes(x, y, color = type_1), size = 4, alpha = 0.5) +
  scale_color_manual("Type", values = unique(setNames(df$color_1, df$color_1))) + 
  theme_minimal() +
  theme(legend.position = "right")


ds <- df %>% 
  select(pokemon, type_1, type_2, weight, height,
         attack, defense, special_attack, special_defense,
         url_image, url_icon, color = color_1, x, y) %>% 
  list.parse3() %>% 
  map(function(x){
    x$marker$symbol <- sprintf("url(%s)", x$url_icon)
    x$marker$radius <- 2
    x$url_icon  <- NULL
    x
  })

ds2 <- df %>% 
  select(color = color_1, x, y) %>%
  mutate(color = hex_to_rgba(color, 0.05)) %>% 
  list.parse3()


tooltip <- names(ds[[1]]) %>% 
  setdiff(c("marker", "url_image", "url_icon", "color", "x", "y",
            "color_1", "color_2", "color_f", "species_id")) %>%
  map(function(x){
    tags$tr(
      tags$th(str_replace_all(str_to_title(x), "_", " ")),
      tags$td(paste0("{point.", x, "}"))
    )
  }) %>% 
  do.call(tagList, .) %>% 
  tagList(
    tags$img(src = "https://raw.githubusercontent.com/phalt/pokeapi/master/data/Pokemon_XY_Sprites/{point.url_image}",
             width = "125px", height = "125px")
  ) %>% 
  as.character()


qt <- function(...) as.numeric(quantile(...))

hctsne <- highchart() %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_xAxis(minRange = diff(range(df$x))/5, min = qt(df$x, 0.01) - 10, max = qt(df$x, 0.99) + 10) %>% 
  hc_yAxis(minRange = diff(range(df$y))/5, min = qt(df$y, 0.01) - 10, max = qt(df$y, 0.99) + 10) %>% 
  hc_add_series(data = ds2, type = "scatter",
                marker = list(radius = 100),
                zIndex = -3,  enableMouseTracking = FALSE) %>%
  hc_add_series(data = ds,
                type = "scatter",
                states = list(hover = list(halo = list(
                  size  = 50,
                  attributes = list(
                    opacity = 1)
                )))) %>%
  hc_plotOptions(series = list()) %>%  
  hc_tooltip(
    useHTML = TRUE,
    borderRadius = 0,
    borderWidth = 5,
    headerFormat = "<table>",
    pointFormat = tooltip,
    footerFormat = "</table>"
  ) %>% 
  hc_add_theme(hc_theme_null())

hctsne


