#' ---
#' title: "Paths & Distances"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---

#+ fig.width=10, fig.height=5

rm(list = ls())
suppressWarnings(library("igraph"))
suppressWarnings(library("magrittr"))


#'# `igraph` Package

str <- "1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 1 1 10 10 9 9 3 3 7"

edges <- str %>% 
  strsplit(" ") %>% 
  unlist() %>% 
  as.numeric() %>%
  matrix(nrow = 2, byrow = FALSE)

edges2 <- letters[edges] %>% 
  matrix(nrow = 2, byrow = FALSE)

g <- graph.empty(10, directed = FALSE)

g <- add.edges(g, edges)

plot(g)

shortest.paths(g, mode = "out")

get.all.shortest.paths(g, 1, 6:8)

get.shortest.paths(g, 5)


g <- erdos.renyi.game(100, 1/100)

plot(g)

degree.distribution(g)

