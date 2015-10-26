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

system.time({
 dfmoves <- adply(chesswc %>% select(pgn, game_id), .margins = 1, function(x){
   chss <- Chess$new()
   chss$load_pgn(x$pgn)
   chss$history_detail()
 }, .parallel = TRUE, .paropts = list(.packages = c("rchess")))
})

#' ### The beautiful result    
dfmoves <- tbl_df(dfmoves) %>% select(-pgn)
head(dfmoves)

#' ### Auxiliar dataframe
dfboard <- rchess:::.chessboarddata() %>%
  select(cell, col, row, x, y, cc)
dfboard

#' ### Join
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

#' #### Path
#' The f1 Bishop
ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfmoves %>% filter(piece == "f1 Bishop", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = 0.50, angle = -45, alpha = 0.02, color = "white", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = dfmoves %>% filter(piece == "f1 Bishop", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = -0.50, angle = 45, alpha = 0.02, color = "white", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() +
  ggthemes::theme_map() +
  ggtitle("f1 Bishop") + 
  theme(legend.position = "none")
  
#' # The g8 Knight
ggplot() + 
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfmoves %>% filter(piece == "g8 Knight", x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = 0.50, angle = -45, alpha = 0.02, color = "black", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = dfmoves %>% filter(piece == "g8 Knight", !x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to),
             curvature = -0.50, angle = 45, alpha = 0.02, color = "black", size = 1.05,
             arrow = arrow(length = unit(0.25,"cm"))) +
  scale_fill_manual(values =  c("gray80", "gray90")) +
  coord_equal() +
  ggthemes::theme_map() +
  ggtitle("g8 Knight") + 
  theme(legend.position = "none")


#' # All pieces just because we can
#+ dpi = 216
ggplot() +
  geom_tile(data = dfboard, aes(x, y, fill = cc)) +
  geom_curve(data = dfmoves %>% filter(x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to, color = piece_color),
             curvature = 0.50, angle = -45, alpha = 0.02,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = dfmoves %>% filter(!x_gt_y_equal_xy_sign),
             aes(x = x.from, y = y.from, xend = x.to, yend = y.to, color = piece_color),
             curvature = -0.50, angle = 45, alpha = 0.02,
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

#' #### Suvival rates

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
  scale_fill_gradient(low = "red",  high = "white") + 
  geom_text(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, label = scales::percent(surv_rate)), color = "gray20") +
  theme_minimal() + 
  scale_x_continuous(breaks = 1:8, labels = letters[1:8]) +
  scale_y_continuous(breaks = 1:8, labels = 1:8)  + 
  geom_segment(data=dfboard2, aes(x=x, y=y, xend=xend, yend=yend), color = "gray70") + 
  geom_segment(data=dfboard2, aes(x=y, y=x, xend=yend, yend= xend), color = "gray70") + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.title = element_blank()) +
  coord_equal() + 
  ggtitle("Survival Rates for each piece")
  
str(dfsurvrates)


ggplot(dfsurvrates) + 
  geom_tile(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, fill = 100*surv_rate)) + 
  scale_fill_gradient(NULL, low = "red",  high = "white") + 
  geom_text(data = dfsurvrates %>% filter(!is.na(surv_rate)),
            aes(x, y, label = unicode), size = 10, color = "gray20", alpha = 0.7) +
  theme_minimal() + 
  scale_x_continuous(breaks = 1:8, labels = letters[1:8]) +
  scale_y_continuous(breaks = 1:8, labels = 1:8)  + 
  geom_segment(data=dfboard2, aes(x=x, y=y, xend=xend, yend=yend), color = "gray70") + 
  geom_segment(data=dfboard2, aes(x=y, y=x, xend=yend, yend= xend), color = "gray70") + 
  theme(legend.position = "bottom",
        panel.grid = element_blank(),
        axis.title = element_blank()) +
  coord_equal() + 
  ggtitle("Survival Rates for each piece")

str(dfsurvrates)

