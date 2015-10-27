#' ---
#' title: "Chess Vizs"
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

#' ### Intro
#' - Pieces movements
#' - Piece survavility
#' - Square usage by player
#' - tree movements

#' ### The Data
data(chesswc)
head(chesswc)

chesswc %>% count(event)
chesswc %>% count(white) %>% arrange(desc(n))

chesswc <- chesswc %>% filter(event == "FIDE World Cup 2015")

#' ### Problem format
#+ eval=FALSE, results='hide'
system.time({
  pgn <- sample(chesswc$pgn, size = 1)
  chss <- Chess$new()
  chss$load_pgn(pgn)
  chss$history_detail()
})

#' ### Parallel process
library("foreach")
library("doParallel")
workers <- makeCluster(parallel::detectCores())
registerDoParallel(workers)

chesswc <- chesswc %>% mutate(game_id = seq(nrow(.)))

dfmoves <- adply(chesswc %>% select(pgn, game_id), .margins = 1, function(x){
  chss <- Chess$new()
  chss$load_pgn(x$pgn)
  chss$history_detail()
  }, .parallel = TRUE, .paropts = list(.packages = c("rchess")))

#' ### The beautiful result    
dfmoves <- tbl_df(dfmoves) %>% select(-pgn)
head(dfmoves)

#' ### Auxiliar dataframe
dfboard <- rchess:::.chessboarddata() %>%
  select(cell, col, row, x, y, cc)
dfboard

#' ### Join
dfpaths <- dfmoves %>% 
  left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
  mutate(x_gt_y = abs(x.to - x.from) > abs(y.to - y.from),
         xy_sign = sign((x.to - x.from)*(y.to - y.from)) == 1,
         x_gt_y_equal_xy_sign = x_gt_y == xy_sign)

#' # Details
piece_lvls <- dfpaths %>%
  filter(piece_number_move == 1) %>%
  select(piece, col, row) %>%
  distinct() %>% 
  arrange(desc(row), col) %>% 
  .$piece

dfpaths <- dfpaths %>% 
  mutate(piece = factor(piece, levels = piece_lvls),
         piece_color = ifelse(str_extract(piece, "\\d") %in% c("1", "2"), "white", "black"),
         piece_color = ifelse(str_detect(piece, "White"), "white", piece_color))

#' ### Paths
#' The f1 Bishop
ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(piece == "f1 Bishop", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = 0.50, angle = -45, alpha = 0.02, color = "white", size = 1.05) + 
  geom_curve(data = dfpaths %>% filter(piece == "f1 Bishop", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = -0.50, angle = 45, alpha = 0.02, color = "white", size = 1.05) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() +
  ggthemes::theme_map() +
  ggtitle("f1 Bishop") + 
  theme(legend.position = "none", title = element_text(size = 12))
  
#' # The g8 Knight
ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(piece == "g8 Knight", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = 0.50, angle = -45, alpha = 0.02, color = "black", size = 1.05) + 
  geom_curve(data = dfpaths %>% filter(piece == "g8 Knight", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = -0.50, angle = 45, alpha = 0.02, color = "black", size = 1.05) +
  scale_fill_manual(values =  c("gray80", "gray90")) +
  coord_equal() +
  ggthemes::theme_map() +
  ggtitle("g8 Knight") + 
  theme(legend.position = "none", title = element_text(size = 12))


#' # All pieces just because we can
#+ dpi = 216
ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to, color = piece_color),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = 0.50, angle = -45, alpha = 0.02) + 
  geom_curve(data = dfpaths %>% filter(!x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to, color = piece_color),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = -0.50, angle = 45, alpha = 0.02) +
  scale_fill_manual(values =  c("gray40", "gray60")) +
  scale_color_manual(values =  c("black", "white")) +
  facet_wrap(~piece, nrow = 4, ncol = 8) + 
  coord_equal() +
  ggthemes::theme_map() +
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text = element_text(size = 6))

# ggsave("~/../Desktop/Rplot.pdf", width = 16, height = 9, scale = 2)

#' ### Suvival rates

dfsurvrates <- dfmoves %>%
  filter(!is.na(status)) %>% 
  group_by(piece) %>% 
  summarize(games = n(),
            was_captured = sum(status == "captured")) %>% 
  mutate(surv_rate = 1 - was_captured/games)

dfsurvrates <- dfsurvrates %>%
  left_join(rchess:::.chesspiecedata() %>% select(start_position, piece = name, color, unicode),
            by = "piece") %>% 
  full_join(dfboard %>% rename(start_position = cell),
            by = "start_position")

dfboard2 <- data_frame(x = 0:8 + 0.5, y = 0 + 0.5, xend = 0:8 + 0.5, yend = 8 + 0.5)

ggplot(dfsurvrates) + 
  geom_tile(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, fill = surv_rate)) + 
  scale_fill_gradient(low = "darkred",  high = "white") + 
  geom_text(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, label = scales::percent(surv_rate)),
            color = "gray70", size = 4) +
  theme_minimal() + 
  scale_x_continuous(breaks = 1:8, labels = letters[1:8]) +
  scale_y_continuous(breaks = 1:8, labels = 1:8)  + 
  geom_segment(data = dfboard2, aes(x, y, xend = xend, yend = yend), color = "gray70") + 
  geom_segment(data = dfboard2, aes(y, x, xend = yend, yend = xend), color = "gray70") + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.title = element_blank()) +
  coord_equal() + 
  ggtitle("Survival Rates for each piece")
  

ggplot(dfsurvrates) + 
  geom_tile(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, fill = 100*surv_rate)) + 
  scale_fill_gradient(NULL, low = "darkred",  high = "white") + 
  geom_text(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, label = unicode), size = 8, color = "gray20", alpha = 0.7) +
  theme_minimal() + 
  scale_x_continuous(breaks = 1:8, labels = letters[1:8]) +
  scale_y_continuous(breaks = 1:8, labels = 1:8)  + 
  geom_segment(data = dfboard2, aes(x, y, xend = xend, yend = yend), color = "gray70") + 
  geom_segment(data = dfboard2, aes(y, x, xend = yend, yend = xend), color = "gray70") + 
  theme(legend.position = "bottom",
        panel.grid = element_blank(),
        axis.title = element_blank()) +
  coord_equal() + 
  ggtitle("Survival Rates for each piece")


#' ### Square usage by player
count(chesswc, white) %>% arrange(desc(n))

players <- count(chesswc, white) %>% arrange(desc(n)) %>% .$white %>% head(4)

dfmov_players <- ldply(players, function(p){ # p <- sample(players, size = 1)
  games <- chesswc %>% filter(white == p) %>% .$game_id
  dfres <- dfmoves %>%
    filter(game_id %in% games, !is.na(to)) %>%
    count(to) %>%
    mutate(player = p,
           p = n/length(games))
  dfres
})

dfmov_players <- dfmov_players %>%
  rename(cell = to) %>%
  left_join(dfboard, by = "cell")

ggplot(dfmov_players) + 
  geom_tile(aes(x, row, fill = p)) +
  scale_fill_gradient("Movements to every cell\n(normalized by games)") + 
  geom_text(aes(x, row, label = round(p, 2)), color = "white", alpha = 0.5) +
  facet_wrap(~player) + 
  coord_equal() +
  theme_minimal() + 
  scale_x_continuous(breaks = 1:8, labels = letters[1:8]) +
  scale_y_continuous(breaks = 1:8, labels = 1:8)  + 
  geom_segment(data = dfboard2, aes(x, y, xend = xend, yend = yend), color = "gray70") + 
  geom_segment(data = dfboard2, aes(y, x, xend = yend, yend = xend), color = "gray70") + 
  theme(legend.position = "bottom",
        panel.grid = element_blank(),
        axis.title = element_blank())



#' ### Distributions of the pieces first movement and when pieces are captured
dfmoves_first_mvm <- dfmoves %>% 
  mutate(piece = factor(piece, levels = piece_lvls)) %>% 
  filter(piece_number_move == 1)

ggplot(dfmoves_first_mvm) + 
  geom_density(aes(number_move), fill = "darkblue", alpha = 0.8, color = NA) + 
  theme_minimal() + 
  scale_y_continuous(breaks = NULL) +
  facet_wrap(~piece, nrow = 4, ncol = 8)  +
  xlim(0, 75)

#' ### Captured by
#' 
library("igraph")
library("ForceAtlas2")

dfcaputures <- dfmoves %>% 
  filter(status == "captured") %>% 
  count(piece, captured_by) %>% 
  arrange(desc(n))

dfvertices <- rchess:::.chesspiecedata() %>%
  select(-fen, -start_position) %>% 
  mutate(color = ifelse(color == "w", "gray20", "gray80"))

g <- graph.data.frame(dfcaputures %>% select(captured_by, piece, weight = n),
                      directed = TRUE,
                      vertices = dfvertices)

set.seed(123)
lout <- layout.forceatlas2(g, iterations = 5000, plotstep = 0)

dfvertices <- dfvertices %>% 
  mutate(x = lout[, 1],
         y = lout[, 2])
  
dfedges <- as_data_frame(g, "edges") %>% 
  tbl_df() %>% 
  left_join(dfvertices %>% select(from = name, x, y), by = "from") %>% 
  left_join(dfvertices %>% select(to = name, xend = x, yend = y), by = "to")


p <- ggplot() + 
  geom_curve(data = dfedges %>% filter((str_extract(from, "\\d+") %in% c(1, 2) | str_detect(from, "White"))),
             aes(x, y, xend = xend, yend = yend, alpha = weight, size = weight),
             curvature = 0.1, color = "red") +
  geom_curve(data = dfedges %>% filter(!(str_extract(from, "\\d+") %in% c(1, 2) | str_detect(from, "White"))),
             aes(x, y, xend = xend, yend = yend, alpha = weight, size = weight),
             curvature = 0.1, color = "blue") +
  scale_alpha(range = c(0.01, 0.5)) + 
  scale_size(range = c(0.01, 2)) + 
  geom_point(data = dfvertices, aes(x, y, color = color), size = 22, alpha = 0.9) + 
  scale_color_manual(values = c("gray90", "gray10")) +
  geom_text(data = dfvertices, aes(x, y, label = name), size = 3, color = "gray50") +
  theme_minimal() +
  theme(legend.position = "none",
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank()) +
  ggtitle("Red path: white captures black | Blue path: black captures white")

p
p + geom_rect(aes(xmin = -220, xmax = -100, ymin = 48900, ymax = 49090), alpha = 0.2)

dfmoves %>% filter(captured_by == "g1 Knight", piece == "c7 Pawn")
dfmoves %>% filter(captured_by == "c7 Pawn", piece == "d2 Pawn")

