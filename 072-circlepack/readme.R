# ws ----------------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(gsheet)
library(highcharter)

library(igraph)
library(ggraph)

# data --------------------------------------------------------------------
set.seed(1)
data <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1CH4Q5LmsLRBXf5OCReircx8goicKnz1u6XDvz4WF0Pk/edit#gid=0")
glimpse(data)

tot <- sum(data$gastos_operacionales)

count(data, partido, sort = TRUE)

get_circlepack <- function(data, variable = "partido") {
  
  d <- data %>% 
    select_(.dots = c(variable, "nombre")) %>% 
    setNames(c("from", "to"))  
  d <- data %>% 
    distinct_(.dots = variable) %>% 
    rename_("to" = variable) %>% 
    mutate(from = "ALL") %>% 
    bind_rows(d, .)
  

  v <- data %>% 
    select_(.dots = c("name" = "nombre", "size" = "gastos_operacionales"))
  v <- data %>% 
    group_by_("name" = variable) %>% 
    summarize(size = sum(gastos_operacionales)) %>% 
    bind_rows(v, .)
  v <- data_frame(name = "ALL", size =  sum(data$gastos_operacionales))  %>% 
    bind_rows(v, .)
  
  g <- graph_from_data_frame(d, vertices = v)
  
  d <- create_layout(g, "circlepack") %>% 
    tbl_df() %>% 
    mutate_if(is.factor, as.character) %>% 
    tail(nrow(data)) %>%
    left_join(select_(data, .dots = c("name" = "nombre", "variable" = variable)))
  d
}

get_circlepack(data, "partido")
d <- get_circlepack(data, "region")
d <- get_circlepack(data, "sexo")

d

highchart(type = "map") %>% 
  hc_add_series(mapData = NULL, showInLegend = FALSE) %>% 
  hc_add_series(data = d, type = "mapbubble", mapping = hcaes(x, y, color = variable, z = size),
                maxSize = "8.5%")

 


data <- tbl_df(ggplot_build(gg)[["data"]][[1]])
glimpse(data)


graph <- graph_from_data_frame(flare$edges, vertices = flare$vertices)
highcharter::hchart(graph)
ggraph(graph, 'circlepack', weight = 'size') + 
  geom_node_circle(aes(fill = depth), size = 0.25, n = 50) + 
  coord_fixed()
