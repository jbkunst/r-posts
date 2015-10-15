# Chess movements
Joshua Kunst  



Load data


```r
dfgames <- readRDS("data/dfgames.rds")
dfmoves <- readRDS("data/dfmoves.rds")
```

Plots a chess data


```r
chessboardjs()
```

<!--html_preserve--><div id="htmlwidget-305" style="width:300px;height:300px;" class="chessboardjs"></div>
<script type="application/json" data-for="htmlwidget-305">{"x":{"fen":"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"},"evals":[]}</script><!--/html_preserve-->

Example Game


```r
dfmvex <- dfmoves %>% filter(game_id == 10)
dfmvex
```

```
## Source: local data frame [41 x 10]
## 
##    game_id color  from    to flags piece   san captured number_move
##      (int) (chr) (chr) (chr) (chr) (chr) (chr)    (chr)       (int)
## 1       10     w    g1    f3     n     n   Nf3       NA           1
## 2       10     b    d7    d5     b     p    d5       NA           2
## 3       10     w    b2    b3     n     p    b3       NA           3
## 4       10     b    c7    c5     b     p    c5       NA           4
## 5       10     w    e2    e4     b     p    e4       NA           5
## 6       10     b    d5    e4     c     p  dxe4        p           6
## 7       10     w    f3    g5     n     n   Ng5       NA           7
## 8       10     b    g8    f6     n     n   Nf6       NA           8
## 9       10     w    b1    c3     n     n   Nc3       NA           9
## 10      10     b    b8    c6     n     n   Nc6       NA          10
## ..     ...   ...   ...   ...   ...   ...   ...      ...         ...
## Variables not shown: promotion (chr)
```

Lets check king knigth. This pices start in 


```r
chss <- Chess$new()
chss$clear()
chss$put("n", "w", "g1")
```

```
## [1] TRUE
```

```r
plot(chss)
```

<!--html_preserve--><div id="htmlwidget-9421" style="width:300px;height:300px;" class="chessboardjs"></div>
<script type="application/json" data-for="htmlwidget-9421">{"x":{"fen":"8/8/8/8/8/8/8/6N1 w - - 0 1"},"evals":[]}</script><!--/html_preserve-->

Some details of parameters


```r
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
```

```
## g1 0
## f3 1
## g5 7
## e4 19
## f6 37
## e8 41
```

Creating data to plot


```r
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
```

![](readme_files/figure-html/unnamed-chunk-7-1.png) 

```r
p <- p +
  scale_fill_manual(values =  c("gray10", "gray20")) +
  coord_equal() + 
  ggthemes::theme_map() +
  theme(legend.position = "none")

p
```

![](readme_files/figure-html/unnamed-chunk-7-2.png) 


---
title: "readme.R"
author: "jkunst"
date: "Thu Oct 15 12:52:33 2015"
---
