# Chess Vizs
Joshua Kunst  



### Intro
- Pieces movements
- Piece survavility
- Square usage by player
- tree movements
### The Data


```r
data(chesswc)
head(chesswc)
```

```
## Source: local data frame [6 x 11]
## 
##                 event                site       date round
##                 (chr)               (chr)     (date) (dbl)
## 1 FIDE World Cup 2011 Khanty-Mansiysk RUS 2011-08-28   1.1
## 2 FIDE World Cup 2011 Khanty-Mansiysk RUS 2011-08-28   1.1
## 3 FIDE World Cup 2011 Khanty-Mansiysk RUS 2011-08-28   1.1
## 4 FIDE World Cup 2011 Khanty-Mansiysk RUS 2011-08-28   1.1
## 5 FIDE World Cup 2011 Khanty-Mansiysk RUS 2011-08-28   1.1
## 6 FIDE World Cup 2011 Khanty-Mansiysk RUS 2011-08-28   1.1
## Variables not shown: white (chr), black (chr), result (chr), whiteelo
##   (int), blackelo (int), eco (chr), pgn (chr)
```

```r
chesswc %>% count(event)
```

```
## Source: local data frame [3 x 2]
## 
##                 event     n
##                 (chr) (int)
## 1 FIDE World Cup 2011   393
## 2 FIDE World Cup 2013   430
## 3 FIDE World Cup 2015   419
```

```r
chesswc <- chesswc %>% filter(event == "FIDE World Cup 2015")
```

### Problem format


```r
system.time({
  pgn <- sample(chesswc$pgn, size = 1)
  chss <- Chess$new()
  chss$load_pgn(pgn)
  chss$history_detail()  
})
```

### Parallel process


```r
library("foreach")
library("doParallel")
```

```
## Loading required package: iterators
## Loading required package: parallel
```

```r
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
```

```
##    user  system elapsed 
##    0.34    0.08  126.97
```

### The beautiful result    


```r
dfmoves <- tbl_df(dfmoves) %>% select(-pgn)
head(dfmoves)
```

```
## Source: local data frame [6 x 9]
## 
##   game_id   piece  from    to number_move piece_number_move status
##     (int)   (chr) (chr) (chr)       (int)             (int)  (chr)
## 1       1 a1 Rook    a1    e1          47                 1     NA
## 2       1 a1 Rook    e1    d1          61                 2     NA
## 3       1 a1 Rook    d1    c1          75                 3     NA
## 4       1 a1 Rook    c1    b1          85                 4     NA
## 5       1 a1 Rook    b1    b7          91                 5     NA
## 6       1 a1 Rook    b7    b5          95                 6     NA
## Variables not shown: number_move_capture (int), captured_by (chr)
```

### Auxiliar dataframe


```r
dfboard <- rchess:::.chessboarddata() %>%
  select(cell, col, row, x, y, cc)
dfboard
```

```
## Source: local data frame [64 x 6]
## 
##     cell   col   row     x     y    cc
##    (chr) (chr) (int) (int) (int) (chr)
## 1     a1     a     1     1     1     b
## 2     b1     b     1     2     1     w
## 3     c1     c     1     3     1     b
## 4     d1     d     1     4     1     w
## 5     e1     e     1     5     1     b
## 6     f1     f     1     6     1     w
## 7     g1     g     1     7     1     b
## 8     h1     h     1     8     1     w
## 9     a2     a     2     1     2     w
## 10    b2     b     2     2     2     b
## ..   ...   ...   ...   ...   ...   ...
```

### Join


```r
dfmoves <- dfmoves %>% 
  left_join(dfboard %>% rename(from = cell, x.from = x, y.from = y), by = "from") %>% 
  left_join(dfboard %>% rename(to = cell, x.to = x, y.to = y) %>% select(-cc, -col, -row), by = "to") %>% 
  mutate(x_gt_y = abs(x.to - x.from) > abs(y.to - y.from),
         xy_sign = sign((x.to - x.from)*(y.to - y.from)) == 1,
         x_gt_y_equal_xy_sign = x_gt_y == xy_sign)
```

# Details


```r
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
```

# The f1 Bishop


```r
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
```

![](readme_files/figure-html/unnamed-chunk-9-1.png) 

# The g8 Knight


```r
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
```

![](readme_files/figure-html/unnamed-chunk-10-1.png) 

# All pieces just because we can


```r
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
```

![](readme_files/figure-html/unnamed-chunk-11-1.png) 

```r
# ggsave("~/../Desktop/Rplot.pdf", width = 16, height = 9, scale = 2)
```


---
title: "readme.R"
author: "jkunst"
date: "Mon Oct 26 17:25:28 2015"
---
