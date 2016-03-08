#### Use the stats ####
stts <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")

dftpstats  <- df %>% 
  select(type_1, color_1,
         hp, attack, defense, special_attack, special_defense, speed) %>% 
  gather(stat, value, -type_1, -color_1) %>% 
  group_by(type_1, color_1, stat) %>%
  summarise(value = median(value)) %>% 
  ungroup() %>% 
  mutate(stat = factor(stat, levels = stts)) %>% 
  arrange(type_1, as.numeric(stat))

dftpstats

hcstats <- highchart() %>% 
  hc_chart(type = "line", polar = TRUE) %>% 
  hc_plotOptions(line = list(marker = list(enabled = FALSE))) %>% 
  hc_xAxis(categories = stts,
           tickmarkPlacement = 'on',
           lineWidth = 0) %>% 
  hc_yAxis(gridLineInterpolation = 'polygon',
           lineWidth = 0,
           min = 0) %>% 
  hc_legend(align = "left", verticalAlign = "top",
            layout = "vertical") 

for (tp in unique(dftpstats$type_1)){
  
  dftpstats2 <- dftpstats %>% filter(type_1 == tp)
  
  hcstats <- hcstats %>% 
    hc_add_series(name = tp, data = dftpstats2$value,
                  color = hex_to_rgba(dftpstats2$color_1[1], 0.4))
  
}

hcstats

#### scatter ####
tooltip <- c("pokemon", "type_1", "type_2",
             "weight", "height",
             "attack",  "defense",
             "special_attack", "special_defense") %>%
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

ds <- df %>% 
  mutate(x = attack,
         y = defense,
         color = hex_to_rgba(color_f, 0.05)) %>% 
  list.parse3() %>% 
  map(function(x){
    x$marker$symbol <- sprintf("url(%s)", x$url_icon)
    x$marker$radius <- 2
    x$url_icon  <- NULL
    x
  })

hcattdef <- highchart() %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_add_series(data = ds, type = "scatter",
                states = list(hover = list(halo = list(
                  size  = 50,
                  attributes = list(
                    opacity = 1)
                )))) %>%
  hc_tooltip(
    useHTML = TRUE,
    borderRadius = 0,
    borderWidth = 5,
    headerFormat = "<table>",
    pointFormat = tooltip,
    footerFormat = "</table>"
  ) %>% 
  hc_add_theme(hc_theme_null())

hcattdef
