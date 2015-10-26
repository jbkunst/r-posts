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
knitr::opts_chunk$set(warning = FALSE)
options(stringsAsFactors = FALSE)

#' # Intro
#' Some parameters
url_base  <- "http://www.bakuworldcup2015.com/files/pgn/Round%s.pgn"
url_pgns <- laply(seq(6), function(round){ sprintf(url_base, round)})
url_pgns <- c(url_pgns, "http://www.bakuworldcup2015.com/files/pgn/baku-world-cup-2015.pgn")
url_pgns


#' # The magic parese function
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
  
  df_games <- ldply(seq(nrow(df_cuts)), function(row){ # row <- 3
    
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

#+ eval=FALSE, results='hide'
system.time({
  pgn <- sample(dfgames$pgn, size = 1)
  chss <- Chess$new()
  chss$load_pgn(pgn)
  chss$history_detail()  
})

#' # This took some time 
library("foreach")
library("doParallel")
workers <- makeCluster(parallel::detectCores()/2)
registerDoParallel(workers)


system.time({
 dfmoves <- adply(dfgames %>% select(pgn, game_id), .margins = 1, function(x){
   chss <- Chess$new()
   chss$load_pgn(x$pgn)
   chss$history_detail()
 }, .parallel = TRUE, .paropts = list(.packages = c("rchess")))
})


#' # the beautiful result    
dfmoves <- tbl_df(dfmoves) %>% select(-pgn)
head(dfmoves)


#' # A nice data frame 
dfboard <- rchess:::.chessboarddata() %>%
  select(cell, col, row, x, y, cc)
dfboard

#' # Join
dfmoves <- dfmoves %>% 
  left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
  mutate(x_gt_y = abs(x.to - x.from) > abs(y.to - y.from),
         xy_sign = sign((x.to - x.from)*(y.to - y.from)) == 1,
         x_gt_y_equal_xy_sign = x_gt_y == xy_sign)

#' # Details
piece_lvls <- dfmoves %>%
  filter(piece_number_move == 1) %>%
  select(piece, col, row) %>%
  distinct() %>% 
  arrange(desc(row), col) %>% 
  .$piece

dfmoves <- dfmoves %>% 
  mutate(piece = factor(piece, levels = piece_lvls),
         piece_color = ifelse(str_extract(piece, "\\d") %in% c("1", "2"), "white", "black"),
         piece_color = ifelse(str_detect(piece, "White"), "white", piece_color))


#' # The g1 Knight
ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfmoves %>% filter(piece == "g1 Knight", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = 0.50, angle = -45, alpha = 0.01, color = "white", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = dfmoves %>% filter(piece == "g1 Knight", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = -0.50, angle = 45, alpha = 0.01, color = "white", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) +
  scale_fill_manual(values =  c("gray40", "gray60")) +
  coord_equal() +
  ggthemes::theme_map() +
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text = element_text(size = 10))
  

#' # The f8 Bishop
ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfmoves %>% filter(piece == "f8 Bishop", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = 0.50, angle = -45, alpha = 0.01, color = "black", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = dfmoves %>% filter(piece == "f8 Bishop", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = -0.50, angle = 45, alpha = 0.01, color = "black", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) +
  scale_fill_manual(values =  c("gray40", "gray60")) +
  coord_equal() +
  ggthemes::theme_map() +
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text = element_text(size = 10))


#+ results='hide'
dfmoves2 <- dfmoves %>% sample_frac(20/100)

#' # All pieces just because we can


#+ dpi = 216
ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfmoves2 %>% filter(x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to, color = piece_color),
             curvature = 0.50, angle = -45, alpha = 0.05,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = dfmoves2 %>% filter(!x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to, color = piece_color),
             curvature = -0.50, angle = 45, alpha = 0.05,
             arrow = arrow(length = unit(0.25,"cm"))) +
  scale_fill_manual(values =  c("gray40", "gray60")) +
  scale_color_manual(values =  c("black", "white")) +
  facet_wrap(~piece, nrow = 4, ncol = 8) + 
  coord_equal() +
  ggthemes::theme_map() +
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text = element_text(size = 6))

# ggsave("~/../Desktop/Rplot.pdf", width = 16, height = 9, scale = 2)

