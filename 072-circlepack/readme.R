# ws ----------------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(highcharter)
library(gsheet)
library(igraph)
library(ggraph)

# data --------------------------------------------------------------------
set.seed(1)
data <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1CH4Q5LmsLRBXf5OCReircx8goicKnz1u6XDvz4WF0Pk/edit#gid=0")
glimpse(data)

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
  
  select(d, x, y, name, variable, size)
}

d <- get_circlepack(data, "partido")
# d <- get_circlepack(data, "region")
# d <- get_circlepack(data, "sexo")

highchart(type = "map") %>% 
  hc_add_series(mapData = NULL, showInLegend = FALSE) %>% 
  hc_add_series(data = d, type = "mapbubble", mapping = hcaes(x, y, color = variable, z = size),
                maxSize = "8.5%")


vars <- c("sexo", "region", "partido")

dmotion <- map(vars, get_circlepack, data = data)
dmotion <- reduce(dmotion, bind_rows)

dinit <- distinct(dmotion, name, .keep_all = TRUE)

dseqs <- dmotion %>% 
  group_by(name) %>% 
  do(sequence = list_parse(select(., x, y)))

dhc <- left_join(dinit, dseqs)

highchart(type = "map") %>% 
  hc_add_series(mapData = NULL, showInLegend = FALSE) %>% 
  hc_add_series(data = dhc, type = "mapbubble", mapping = hcaes(x, y, color = variable, z = size),
                maxSize = "8.5%") %>% 
  hc_motion(series = 1, enabled = TRUE, labels = vars)



 