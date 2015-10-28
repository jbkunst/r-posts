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

#' There are nice visualizations from chess data: [piece movement](),
#' [piece survaviliy](), [square usage by player](). 
#' Sadly not always the authors shows the code/data for replicate the final result. 
#' So I write some code to show how to do some this great visualizations entirely in
#' R. Just for fun.

#' ### The Data
#' The original data data come from [here](http://www.theweekinchess.com/chessnews/events/fide-world-cup-2015)
#' which was parsed for example data in the [rchess]() package.

data(chesswc)
str(chesswc)

chesswc %>% count(event)
chesswc %>% count(white) %>% arrange(desc(n))

chesswc <- chesswc %>% filter(event == "FIDE World Cup 2015")

#' The most important variable here is the [pgn](https://en.wikipedia.org/wiki/Portable_Game_Notation) game. 
#' However the way to represent the game is not computer/visualization frienly (imo). That's is why
#' I implemented the `history_detail()` method for a `Chess` object.

pgn <- sample(chesswc$pgn, size = 1)
str_sub(pgn, 0, 50)

chss <- Chess$new()
chss$load_pgn(pgn)

chss$history_detail()

#' The result is a dataframe where each row is a piece's movement showing explicitly the cells
#' where the travel in a particular number move. Now we apply this function over the 433
#' games in the last FIDE World cup.
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

dfmoves <- tbl_df(dfmoves) %>% select(-pgn)
dfmoves

#' ### Piece Movements
#' To try replicate the result it's necessary a data to represent (and then plot) the 
#' board.
dfboard <- rchess:::.chessboarddata() %>%
  select(cell, col, row, x, y, cc)
dfboard

dfpaths <- dfmoves %>% 
  left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
  mutate(x_gt_y = abs(x.to - x.from) > abs(y.to - y.from),
         xy_sign = sign((x.to - x.from)*(y.to - y.from)) == 1,
         x_gt_y_equal_xy_sign = x_gt_y == xy_sign)

#' The data is ready! So we need now some `ggplot`, `geom_tile` for the board, the new `geom_curve`
#' to represent the piece's path and some `jitter` to make this more artistic`. Let's
#' start with the fi Bishop.
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
  
#' The g8 Knight and the g1 Knight.
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

ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfpaths %>% filter(piece == "g1 Knight", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = 0.50, angle = -45, alpha = 0.02, color = "white", size = 1.05) + 
  geom_curve(data = dfpaths %>% filter(piece == "g1 Knight", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             position = position_jitter(width = 0.2, height = 0.2),
             curvature = -0.50, angle = 45, alpha = 0.02, color = "white", size = 1.05) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() +
  ggthemes::theme_map() +
  ggtitle("g1 Knight") + 
  theme(legend.position = "none", title = element_text(size = 12))

#' I think it's look very similar to the original source.

#' ### Suvival rates
#' The `dfmoves` is the heart from all these plots beacuse have a lot of information. for example,
#' if we filter for `!is.na(status)` we can know what happend with every piece in every game, if 
#' a piece was caputered of never was captured in the game.
dfsurvrates <- dfmoves %>%
  filter(!is.na(status)) %>% 
  group_by(piece) %>% 
  summarize(games = n(),
            was_captured = sum(status == "captured")) %>% 
  mutate(surv_rate = 1 - was_captured/games)

dfsurvrates %>% arrange(desc(surv_rate)) %>% head()

#' This helps as validation because the kings are never caputred. Now we use a helper function in the
#' rchess package `rchess:::.chesspiecedata()` to get the start position for every piece and thne plot
#' the survival rates in the cell where the piece start in the game.
dfsurvrates <- dfsurvrates %>%
  left_join(rchess:::.chesspiecedata() %>% select(start_position, piece = name, color, unicode),
            by = "piece") %>% 
  full_join(dfboard %>% rename(start_position = cell),
            by = "start_position")

# Auxiliar data to plot the board
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
  
#' Obviously the plot show same data in text and color, and there a lot of space without 
#' information but the idea is use the chess board in fun(?) way. We can replace the 
#' texts with the piece's icons:
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
#' For this visualization we will use the `to` variable. We select the player who have more
#' games in the table `chesswc`.

count(chesswc, white) %>% arrange(desc(n)) %>% head(4)

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
  geom_text(aes(x, row, label = round(p, 2)), size = 2, color = "white", alpha = 0.5) +
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



#' ### Distributions for the first movement
#' Now, with the same data and using the `piece_number_move` and `number_move` we can obtain 
#' the distribution for the first movement for each piece.
piece_lvls <- rchess:::.chesspiecedata() %>%
  mutate(col = str_extract(start_position, "\\w{1}"),
         row = str_extract(start_position, "\\d{1}")) %>% 
  arrange(desc(row), col) %>% 
  .$name

dfmoves_first_mvm <- dfmoves %>% 
  mutate(piece = factor(piece, levels = piece_lvls),
         number_move_2 = ifelse(number_move %% 2 == 0, number_move/2, (number_move+1)/2 )) %>% 
  filter(piece_number_move == 1)

ggplot(dfmoves_first_mvm) + 
  geom_density(aes(number_move_2), fill = "#B71C1C", alpha = 0.8, color = NA) + 
  theme_minimal() + 
  scale_y_continuous(breaks = NULL) +
  facet_wrap(~piece, nrow = 4, ncol = 8, scales = "free_y")  +
  xlim(0, 40)

#' Notice the similarities between the White King and h1 Rook due the castling, the same
#' effect is present between the Black King and the h8 Rook. 

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

lout <- layout.forceatlas2(g, iterations = 1000)

dfvertices <- dfvertices %>% 
  mutate(x = lout[, 1],
         y = lout[, 2])
  
dfedges <- as_data_frame(g, "edges") %>% 
  tbl_df() %>% 
  left_join(dfvertices %>% select(from = name, x, y), by = "from") %>% 
  left_join(dfvertices %>% select(to = name, xend = x, yend = y), by = "to")


ggplot() + 
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

#' ### Bonus content
#' All pieces just because we can
#+ dpi = 216
dfpaths <- dfpaths %>% 
  mutate(piece = factor(piece, levels = piece_lvls),
         piece_color = ifelse(str_extract(piece, "\\d") %in% c("1", "2"), "white", "black"),
         piece_color = ifelse(str_detect(piece, "White"), "white", piece_color))

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
