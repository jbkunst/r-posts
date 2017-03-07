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
options(highcharter.theme = hc_theme_elementary())
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
  mutate(paraderosubida = str_to_title(paraderosubida),
         mediahora = 1000*mediahora)

count(count(data, paraderosubida), n)

data <- mutate(data, mediahora = as.numeric(mediahora))

data <- complete(data, paraderosubida, mediahora,
                 fill = list(subidas_laboral_promedio = 0)) 

data <- filter(data, mediahora != 0)

glimpse(data)

#' ## Correlation

dcor <- data %>%
  pairwise_cor(paraderosubida, mediahora, subidas_laboral_promedio,
               upper = FALSE) %>% 
  arrange(desc(correlation))

head(dcor)
data %>% 
  filter(paraderosubida %in% c("Plaza Maipu", "Laguna Sur")) %>% 
  hchart("line", hcaes(mediahora, subidas_laboral_promedio, group = paraderosubida)) %>% 
  hc_xAxis(type = "datetime") %>% 
  hc_tooltip(sort = TRUE, table = TRUE)
  
tail(dcor)
data %>% 
  filter(paraderosubida %in% c("Universidad De Chile", "Plaza De Puente Alto")) %>% 
  hchart("line", hcaes(mediahora, subidas_laboral_promedio, group = paraderosubida)) %>% 
  hc_xAxis(type = "datetime") %>% 
  hc_tooltip(sort = TRUE, table = TRUE)


# hchart(dcor, "heatmap", hcaes(item1, item2, value = correlation))
dcor1 <- dcor %>%
  arrange(desc(correlation)) %>%
  filter(row_number() <= 400)

# dcor1 <- dcor1 %>% 
#   group_by(item1) %>% 
#   filter(row_number() <= 2) %>% 
#   ungroup() 

g <- graph_from_data_frame(dcor1, directed = FALSE)

E(g)$weight <- dcor1$correlation^2

wc <- cluster_fast_greedy(g)
nc <- length(unique(membership(wc)))

dvert <- data_frame(
  paraderosubida = V(g)$name
  ) %>% 
  mutate(
    comm = membership(wc)
  ) %>% 
  left_join(
    data %>%
      group_by(paraderosubida) %>%
      summarise(n = sum(subidas_laboral_promedio))) %>% 
  left_join(
    data %>%
      group_by(paraderosubida) %>% 
      summarise(tend = cor(seq(1, 37), subidas_laboral_promedio))) %>% 
  ungroup()

dvert
count(dvert, paraderosubida)

# g <- graph_from_data_frame(dcor1, directed = FALSE, vertices = dvert) 
# 
# wc <- cluster_edge_betweenness (g)
# nc <- length(unique(membership(wc)))

V(g)$label <- dvert$paraderosubida
V(g)$size <- dvert$n
V(g)$subidas_totals_miles <- dvert$n/1000
V(g)$comm <- membership(wc)
V(g)$tendencia <- dvert$tend

# V(g)$color <- colorize(dvert$tend)
V(g)$color <- colorize(dvert$comm)


set.seed(1)
hchart(g) %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_add_theme(
    hc_theme_elementary(
      yAxis = list(visible = FALSE),
      xAxis = list(visible = FALSE)
    )
  )


# ex ----------------------------------------------------------------------
left_join(data, dvert) %>% 
  mutate(comm = ifelse(is.na(comm), "Sin com", comm)) %>% 
  ggplot(aes(mediahora, subidas_laboral_promedio, group = paraderosubida, color = comm)) +
  geom_line(alpha = 0.2) +
  geom_smooth(aes(group = comm)) + 
  # scale_x_date() +
  facet_wrap(~comm, ncol = 1, scales = "free_y")

#' ## Autoencoder
data2 <- data %>% 
  group_by(paraderosubida) %>% 
  mutate(subidas_laboral_promedio = scale(subidas_laboral_promedio),
         mediahora = paste0("m", mediahora)) %>% 
  ungroup() %>% 
  spread(mediahora, subidas_laboral_promedio) 

data2

