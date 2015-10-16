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

dfgames <- read_csv("data/chess_magnus.csv.gz")

dfgames <- dfgames %>% head(125)

problems(dfgames)

dfgames  <- dfgames %>% mutate(game_id = seq(nrow(.)))


t0 <- Sys.time()

dfmoves <- dfgames %>%
  group_by(game_id) %>% 
  do({
    mvs <- .$moves %>% strsplit(" ") %>% unlist()
    chss <- Chess$new()
    
    for (mv in mvs) chss$move(mv)
    
    dfhist <- chss$history(verbose = TRUE) %>% 
      mutate(number_move = seq(nrow(.)))
    
    dfhist
    
  }) %>%
  ungroup()

t1 <- Sys.time() - t0
# 
# saveRDS(dfgames, file = "data/dfgames.rds")
# saveRDS(dfmoves, file = "data/dfmoves.rds")
# 
# #' Load data
# dfgames <- readRDS("data/dfgames.rds")
# dfmoves <- readRDS("data/dfmoves.rds")

#' Plots a chess data
chessboardjs()

#' Example Game
dfmvex <- dfmoves %>% filter(game_id == 1)
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
  left_join(dfboard %>% rename(to = cell) %>% select(-cc), by = "to") %>% 
  mutate(curve = ifelse((x.x - x.y) < 0, TRUE, FALSE))


ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(curve),
             aes(x = x.x, y = y.x, xend = x.y, yend = y.y), color = "white", alpha = 0.5, curvature = -.3,
             arrow = arrow(length = unit(0.25,"cm")), position =  position_jitter(w = 0.25, h = 0.25)) +
  geom_curve(data = dfpaths %>% filter(!curve),
             aes(x = x.x, y = y.x, xend = x.y, yend = y.y), color = "white", alpha = 0.25, curvature = .3,
             arrow = arrow(length = unit(0.25,"cm")), position =  position_jitter(w = 0.25, h = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")



dfpaths <- dfmoves %>% 
  group_by(game_id) %>% 
  do({
    dfmvex <- .
    #' Some details of parameters
    pos_start <- "g1"
    pos_current <- pos_start
    pos_nummove <- 0
    piece_was_captured <- FALSE
    path <- NULL
    path <- c(path, pos_current)
    
    while (!piece_was_captured) {
      dfmvex_aux <- dfmvex %>%
        filter(from == pos_current | to == pos_current,
               number_move > pos_nummove) %>% 
        head(1)
      
      if (nrow(dfmvex_aux) == 0) break
      if (dfmvex_aux$to == pos_current) break
      
      pos_current <- dfmvex_aux$to
      pos_nummove <- dfmvex_aux$number_move
      
      path <- c(path, pos_current)
    }
    
    dfpaths <- data_frame(from = head(path, -1),
                          to = tail(path, -1))
    
    dfpaths
    
  })



dfpaths <- dfpaths %>% 
  left_join(dfboard %>% rename(from = cell), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell) %>% select(-cc), by = "to") %>% 
  mutate(curve = ifelse((x.x - x.y) < 0, TRUE, FALSE))


ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(curve),
             aes(x = x.x, y = y.x, xend = x.y, yend = y.y), color = "white", alpha = 0.2, curvature = -.3,
             arrow = arrow(length = unit(0.25,"cm")), position =  position_jitter(w = 0.25, h = 0.25)) +
  geom_curve(data = dfpaths %>% filter(!curve),
             aes(x = x.x, y = y.x, xend = x.y, yend = y.y), color = "white", alpha = 0.2, curvature = .3,
             arrow = arrow(length = unit(0.25,"cm")), position =  position_jitter(w = 0.25, h = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")

ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_point(data = dfpaths, aes(x.x, y.x), position =  position_jitter(w = 0.25, h = 0.25),
             color = "white", alpha = 0.1) +
  geom_curve(data = dfpaths %>% filter(curve),
             aes(x = x.x, y = y.x, xend = x.y, yend = y.y), color = "white", alpha = 0.2, curvature = -.3,
             position =  position_jitter(w = 0.25, h = 0.25)) +
  geom_curve(data = dfpaths %>% filter(!curve),
             aes(x = x.x, y = y.x, xend = x.y, yend = y.y), color = "white", alpha = 0.2, curvature = .3,
             position =  position_jitter(w = 0.25, h = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")




