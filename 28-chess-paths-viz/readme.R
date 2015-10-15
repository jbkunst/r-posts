#' ---
#' title: "Chess movements"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, warning=FALSE, message=FALSE, results='hide'
rm(list = ls())
library("rchess")
library("plyr")
library("dplyr")
library("readr")
library("ggplot2")

# dfgames <- read_csv("data/chess_magnus.csv.gz")
# 
# dfgamesf
# 
# problems(dfgames)
# 
# dfgames  <- dfgames %>% mutate(game_id = seq(nrow(.)))
# 
# 
# t0 <- Sys.time()
# 
# dfmoves <- dfgames %>%
#   group_by(game_id) %>% 
#   do({
#     mvs <- .$moves %>% strsplit(" ") %>% unlist()
#     chss <- Chess$new()
#     
#     for (mv in mvs) chss$move(mv)
#     
#     dfhist <- chss$history(verbose = TRUE) %>% 
#       mutate(number_move = seq(nrow(.)))
#     
#     dfhist
#     
#   }) %>%
#   ungroup()
# 
# t1 <- Sys.time() - t0
# 
# saveRDS(dfgames, file = "data/dfgames.rds")
# saveRDS(dfmoves, file = "data/dfmoves.rds")

#' Load data
dfgames <- readRDS("data/dfgames.rds")
dfmoves <- readRDS("data/dfmoves.rds")

#' Plots a chess data
chessboardjs()

#' Example Game
dfmvex <- dfmoves %>% filter(game_id == 10)
dfmvex

#' Lets check king knigth. This pices start in 
chss <- Chess$new()
chss$clear()
chss$put("n", "w", "g1")
plot(chss)


#' Some details of parameters
pos_start <- "g1"
pos_current <- pos_start
pos_nummove <- 0
piece_was_captured <- FALSE
path <- NULL
path <- c(path, pos_current)

while (!piece_was_captured) {
  message(pos_current, " ", pos_nummove)
  # Maybe the piece was capture and have no movements :(,
  # thats why check from and to variable.
  dfmvex_aux <- dfmvex %>%
    filter(from == pos_current | to == pos_current,
           number_move > pos_nummove) %>% 
    head(1)
  
  # The game is over?
  if (nrow(dfmvex_aux) == 0) break
  
  # Check if the piece was captured :(
  if (dfmvex_aux$to == pos_current) break
  
  pos_current <- dfmvex_aux$to
  pos_nummove <- dfmvex_aux$number_move
  
  path <- c(path, pos_current)
  
}

#' Creating data to plot
dfboard <- rchess:::.chessboarddata() %>% select(cell, col, row, x, y, cc)

dfpaths <- data_frame(from = head(path, -1),
                      to = tail(path, -1))

dfpaths <- dfpaths %>% 
  left_join(dfboard %>% rename(from = cell), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell) %>% select(-cc), by = "to")


p <- ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_segment(data = dfpaths, aes(x = x.x, y = y.x, xend = x.y, yend = y.y),
               color = "white", alpha = 0.7) 

p 

p <- p +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")

p




