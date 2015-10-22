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
options(stringsAsFactors = FALSE)

#' Some parameters
url_base  <- "http://www.bakuworldcup2015.com/files/pgn/Round%s.pgn"
url_pgns <- laply(seq(6), function(round){ sprintf(url_base, round)})
url_pgns <- c(url_pgns, "http://www.bakuworldcup2015.com/files/pgn/baku-world-cup-2015.pgn")
url_pgns


dfgames <- ldply(url_pgns, function(url_pgn) {
  # url_pgn <- sample(url_pgns, size = 1)
  # url_pgn <- "http://www.bakuworldcup2015.com/files/pgn/Round1.pgn"
  pgn_lines <- readLines(url_pgn, warn = FALSE)
  
  idx <- which(pgn_lines == "[Event \"FIDE World Chess Cup\"]")
  idxp1 <- idx + 1
  idxm1 <- idx - 1
  
  pgn_lines[pgn_lines == "[Event \"FIDE World Chess Cup\"]"] <- ""
  idxm1 <- idxm1[idxm1 >= 1]
  idxp1 <- idxp1[idxp1 <= length(pgn_lines)]
  pgn_lines <- pgn_lines[-c(idxp1, idxm1)]
  pgn_lines <- c("", pgn_lines)
  
  where_is_no_info <- which(str_length(pgn_lines) == 0)
  where_is_no_info <- where_is_no_info[seq(length(where_is_no_info)) %% 2 == 0]
  where_is_no_info <- c(0, where_is_no_info)
  
  df_cuts <- data_frame(from = head(where_is_no_info, -1) + 1,
                        to = tail(where_is_no_info, -1) - 1)
  
  df_cuts <- df_cuts %>% filter(!from == to)
  
  df_games <- ldply(seq(nrow(df_cuts)), function(row){ # row <- 1
    
    pgn <- pgn_lines[seq(df_cuts[row, ]$from, df_cuts[row, ]$to)]
    
    headers <- pgn[1:(which(pgn == "") - 1)]
    
    data_keys <- str_extract(headers, "\\w+")
    data_vals <- str_extract(headers, "\".*\"") %>% str_replace_all("\"", "")
    
    pgn2 <- pgn[(which(pgn == "") + 1):length(pgn)]
    pgn2 <- paste0(pgn2, collapse = "")
    pgn2 <- str_replace_all(pgn2, "\\{\\[%clk( |)\\d+:\\d+:\\d+\\]\\}", "")
    
    df_game <- t(data_vals) %>%
      data.frame(stringsAsFactors = FALSE) %>%
      setNames(data_keys) %>% 
      mutate(pgn = pgn2)
    
    df_game
    
  }, .progress = "win")
  
  df_games <- tbl_df(df_games)
  
  df_games
  
}, .progress = "win")

dfgames <- tbl_df(dfgames)

dfgames <- dfgames %>% mutate(game_id = seq(nrow(.)))

tail(dfgames)

system.time({
  pgn <- sample(dfgames$pgn, size = 1)
  chss <- Chess$new()
  chss$load_pgn(pgn)
  chss$history_detail()  
})

library("foreach")
library("doParallel")
workers <- makeCluster(parallel::detectCores()) # My computer has 2 cores
registerDoParallel(workers)

# system.time({
#   history1 <- adply(head(dfgames, 20) %>% select(pgn, game_id), .margins = 1, function(x){
#     chss <- Chess$new()
#     chss$load_pgn(x$pgn)
#     chss$history_detail()
#   })
# })
# 
# system.time({
#   history2 <- adply(head(dfgames, 20) %>% select(pgn, game_id), .margins = 1, function(x){
#     chss <- Chess$new()
#     chss$load_pgn(x$pgn)
#     chss$history_detail()
#   }, .parallel = TRUE, .paropts = list(.packages = c("rchess")))
# })
# 
# all.equal(history1, history2)
# rm(history1, history2)
   
system.time({
 dfhistory <- adply(dfgames %>% select(pgn, game_id), .margins = 1, function(x){
   chss <- Chess$new()
   chss$load_pgn(x$pgn)
   chss$history_detail()
 }, .parallel = TRUE, .paropts = list(.packages = c("rchess")))
})
   
dfhistory <- tbl_df(dfhistory) %>% select(-pgn)

head(dfhistory)

dfhistory %>%
  filter(piece == "White King") %>%
  count(game_id) %>% 
  arrange(desc(n))


dfhist <- dfhistory %>% filter(game_id == 312, piece == "White King")

dfhist
dfboard <- rchess:::.chessboarddata() %>% select(cell, col, row, x, y, cc)

dfboard

dfhist <- dfhist %>% 
  left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
  mutate(curve = ifelse((x.from - x.to) < 0, TRUE, FALSE))


ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfhist %>% filter(curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.5, curvature = 1, angle = -55,
             arrow = arrow(length = unit(0.25,"cm")),
             position =  position_jitter(width = 0.25, height = 0.25)) +
  geom_curve(data = dfhist %>% filter(!curve),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             color = "white", alpha = 0.5, curvature = .3,
             arrow = arrow(length = unit(0.25,"cm")),
             position =  position_jitter(width = 0.25, height = 0.25)) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")
