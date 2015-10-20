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
library("stringr")
library("readr")
library("ggplot2")
library("doParallel")
options(stringsAsFactors = FALSE)

#' Some parameters

url_base  <- "http://www.bakuworldcup2015.com/files/pgn/Round%s.pgn"

url_pgns <- laply(seq(6), function(round){ sprintf(url_base, round)})
url_pgns <- c(url_pgns, "http://www.bakuworldcup2015.com/files/pgn/baku-world-cup-2015.pgn")

url_pgns


games <- ldply(url_pgns, function(url_pgn) {
  # url_pgn <- sample(url_pgns, size = 1)
  # url_pgn <- "http://www.bakuworldcup2015.com/files/pgn/Round1.pgn"
  pgn_lines <- readLines(url_pgn, warn = FALSE)
  
  idx <- which(pgn_lines == "[Event \"FIDE World Chess Cup\"]")
  idxp1 <- idx + 1
  idxm1 <- idx - 1
  
  pgn_lines[pgn_lines == "[Event \"FIDE World Chess Cup\"]"] <- ""
  idxm1 <- idxm1[idxm1>=1]
  idxp1 <- idxp1[idxp1<=length(pgn_lines)]
  pgn_lines <- pgn_lines[-c(idxp1, idxm1)]
  pgn_lines <- c("", pgn_lines)
  
  where_is_no_info <- which(str_length(pgn_lines) == 0)
  where_is_no_info <- where_is_no_info[seq(length(where_is_no_info)) %% 2 == 0]
  where_is_no_info <- c(0, where_is_no_info)
  
  df_cuts <- data_frame(from = head(where_is_no_info, -1) + 1,
                        to = tail(where_is_no_info, -1) - 1)
  
  df_games <- ldply(seq(nrow(df_cuts)), function(row){ # row <- 2
    
    pgn <- pgn_lines[seq(df_cuts[row, ]$from, df_cuts[row, ]$to)]
    
    data_keys <- str_extract(headers, "\\w+")
    data_vals <- str_extract(headers, "\".*\"") %>% str_replace_all("\"", "")
    
    df_game <- t(data_vals) %>%
      data.frame(stringsAsFactors = FALSE) %>%
      setNames(data_keys) %>%
      mutate(moves = paste0(moves, collapse = " "))
    
    df_game
  }, .progress = "win")
  
}, .progress = "win")

games <- tbl_df(games)

games <- ldply(url_pgns, function(url_pgn) {
  # url_pgn <- sample(url_pgns, size = 1)
  # url_pgn <- "http://www.bakuworldcup2015.com/files/pgn/Round1.pgn"
  pgn_lines <- readLines(url_pgn, warn = FALSE)
  
  idx <- which(pgn_lines == "[Event \"FIDE World Chess Cup\"]")
  idxp1 <- idx + 1
  idxm1 <- idx - 1
  
  pgn_lines[pgn_lines == "[Event \"FIDE World Chess Cup\"]"] <- ""
  idxm1 <- idxm1[idxm1>=1]
  idxp1 <- idxp1[idxp1<=length(pgn_lines)]
  pgn_lines <- pgn_lines[-c(idxp1, idxm1)]
  pgn_lines <- c("", pgn_lines)
  
  where_is_no_info <- which(str_length(pgn_lines) == 0)
  where_is_no_info <- where_is_no_info[seq(length(where_is_no_info)) %% 2 == 0]
  where_is_no_info <- c(0, where_is_no_info)
  
  df_cuts <- data_frame(from = head(where_is_no_info, -1) + 1,
                        to = tail(where_is_no_info, -1) - 1)
  
  df_games <- ldply(seq(nrow(df_cuts)), function(row){ # row <- 2
    
    pgn <- pgn_lines[seq(df_cuts[row, ]$from, df_cuts[row, ]$to)]
    
    data_keys <- str_extract(headers, "\\w+")
    data_vals <- str_extract(headers, "\".*\"") %>% str_replace_all("\"", "")
    
    df_game <- t(data_vals) %>%
      data.frame(stringsAsFactors = FALSE) %>%
      setNames(data_keys) %>%
      mutate(moves = paste0(moves, collapse = " "))
    
    df_game
  }, .progress = "win")
  
}, .progress = "win")

games <- tbl_df(games)

## data for moves
moves <- pgn[seq(which(pgn == "") + 1, length(pgn))] %>% 
  paste0(collapse = " ") %>% 
  str_replace_all("\\{\\[%clk \\d+:\\d+:\\d+\\]\\}", "" ) %>% # remove times
  str_split("\\d+\\.|\\s+") %>%
  unlist() %>% 
  .[. != ""] %>% 
  head(-1) # remove final result

## data game
headers <- pgn[seq(which(pgn == "")) - 1]


games %>% select(-moves) %>% str()


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

