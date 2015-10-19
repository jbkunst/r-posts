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
library("doParallel")

dfgames <- read_csv("data/chess_magnus.csv.gz")

str(dfgames)


moves_to_hist_df <- function(moves){ # moves <- sample(size = 1, dfgames$moves)
  
  mvs <- moves %>% strsplit(" ") %>% unlist()
  chss <- Chess$new()
  
  for (mv in mvs) chss$move(mv)
  
  dfhist <- chss$history(verbose = TRUE) %>% 
    mutate(number_move = seq(nrow(.)))
  
  return((dfhist))
  
}

dfgames$moves[1]

moves_to_hist_df(dfgames$moves[1])



cl <- makeCluster(detectCores())
registerDoParallel(cl)

dfmoves <- foreach(moves = dfgames$moves,
                   .combine = rbind.fill,
                   .packages = c("magrittr", "rchess", "dplyr")) %dopar%
  moves_to_hist_df(moves)

stopCluster(cl)


dfmoves <- tbl_df(dfmoves)
dfmoves <- dfmoves %>% mutate(game_id = number_move - lag(number_move))
 


#' Example Game
dfmvex <- dfmoves %>% filter(game_id == 1)
dfmvex

#' Lets check king knigth. This pices start in 
chss <- Chess$new()
chss$clear()
chss$put("n", "w", "g1")

plot(chss, type = "ggplot")

chss$move("Nf3")$plot(type = "ggplot")


#' Some details of parameters
pos_start <- "g1"
pos_current <- pos_start
pos_nummove <- 0
piece_was_captured <- FALSE
path <- NULL
path <- c(path, pos_current)

while (!piece_was_captured) {
  # message(pos_current, " ", pos_nummove)
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


path 

dfpaths <- data_frame(from = head(path, -1),
                      to = tail(path, -1))

dfpaths

#' Creating data to plot
dfboard <- rchess:::.chessboarddata() %>% select(cell, col, row, x, y, cc)

dfboard


dfpaths <- dfpaths %>% 
  left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
  mutate(curve = ifelse((x.from - x.to) < 0, TRUE, FALSE))


ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.5, curvature = 1, angle = -55,
             arrow = arrow(length = unit(0.25,"cm")),
             position =  position_jitter(width = 0.25, height = 0.25)) +
  geom_curve(data = dfpaths %>% filter(!curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.5, curvature = .3,
             arrow = arrow(length = unit(0.25,"cm")),
             position =  position_jitter(width = 0.25, height = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")



get_paths_from_position <- function(position) {
  
  dfresponse <- dfmoves %>% 
    group_by(game_id) %>% 
    do({
      dfmvex <- .
      #' Some details of parameters
      pos_start <- position
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
  
  dfresponse <- dfresponse %>% 
    left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
    left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
    mutate(curve = ifelse((x.from - x.to) < 0, TRUE, FALSE))
  
  dfresponse
  
  
}

dfpaths_g1 <- get_paths_from_position("g1") %>% sample_frac(0.2)

ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths_g1 %>% filter(curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.1, curvature = 0.75, angle = -45,
             position =  position_jitter(width = 0.25, height = 0.25)) +
  geom_curve(data = dfpaths_g1 %>% filter(!curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.1, curvature = 0.75, angle = -45,
             position =  position_jitter(width = 0.25, height = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")


dfpaths_d1 <- get_paths_from_position("d1") %>% sample_frac(0.2)

ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths_g1 %>% filter(curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.1, curvature = 0.75, angle = -45,
             position =  position_jitter(width = 0.25, height = 0.25)) +
  geom_curve(data = dfpaths_g1 %>% filter(!curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.1, curvature = 0.75, angle = -45,
             position =  position_jitter(width = 0.25, height = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")

