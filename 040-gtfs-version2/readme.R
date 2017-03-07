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
library(tidyverse)
library(stringr)
library(widyr)
library(igraph)
library(highcharter)

#'
#' Read data
#' 
#' http://www.dtpm.gob.cl/index.php/2013-04-29-20-33-57/matrices-de-viaje



urlfile <- "http://www.dtpm.gob.cl/descargas/archivos/2015.04_Subidas_paradero_mediahora_web.rar"
rarfile <- file.path("data", basename(urlfile))

if(!file.exists(rarfile)) {
  dir.create("data")
  download.file(urlfile, file.path("data", basename(urlfile)), mode = "wb")
}

data <- read_csv2("data/2015.04_Subidas_paradero_mediahora_web/2015.04_Subidas_paradero_mediahora_web.csv")
 
data <- data %>% 
  mutate(subidas_laboral_promedio = as.numeric(subidas_laboral_promedio)) %>% 
  filter(!str_detect(paraderosubida, "^(T|L|I|E)?-")) %>% 
  mutate(paraderosubida = str_to_title(paraderosubida))

count(count(data, paraderosubida), n)

data <- mutate(data, mediahora = as.numeric(mediahora))

data <- complete(data, paraderosubida, mediahora,
                 fill = list(subidas_laboral_promedio = 0)) 

data <- filter(data, mediahora != 0)

glimpse(data)


dcor <- data %>%
  pairwise_cor(paraderosubida, mediahora, subidas_laboral_promedio,
               upper = FALSE)

# hchart(dcor, "heatmap", hcaes(item1, item2, value = correlation))

dcor1 <- dcor %>%
  arrange(desc(correlation)) %>%
  filter(row_number() <= 400)

g <- graph_from_data_frame(dcor1, directed = FALSE)

E(g)$weight <- dcor1$correlation

dvert <- data_frame(paraderosubida = V(g)$name) %>% 
  left_join(data %>%
              group_by(paraderosubida) %>%
              summarise(n = sum(subidas_laboral_promedio))) %>% 
  left_join(data %>% 
              group_by(paraderosubida) %>% 
              summarise(tend = cor(seq(1, 37), subidas_laboral_promedio)))

wc <- cluster_edge_betweenness (g)
nc <- length(unique(membership(wc)))


V(g)$label <- V(g)$name
V(g)$size <- dvert$n
V(g)$color <- colorize(dvert$tend)
V(g)$comm <- membership(wc)


set.seed(1)
hchart(g) %>% 
  hc_add_theme(
    hc_theme_elementary(
      yAxis = list(visible = FALSE),
      xAxis = list(visible = FALSE)
    )
  )

# dcor2 <- dcor %>% 
#   group_by(item1) %>% 
#   arrange(desc(correlation)) %>% 
#   filter(row_number() <= 3) %>% 
#   ungroup()
# 
# g2 <- graph_from_data_frame(dcor2, directed = FALSE)
# E(g2)$weight <- dcor2$correlation^2
# 
# hchart(g2)
