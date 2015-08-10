#' ---
#' output:
#'   md_document
#' ---

library("ggplot2")
library("ggthemes")
library("grid")

rm(list = ls())
size = 10; by = 2


gg_null <- function(){
  ggplot() + theme_map() +  coord_equal()
}

df_cart_axis <- function(size = 10, by = 2){
  data.frame(x = c(-size, 0), y = c(0, -size),
             xend = c(size, 0), yend = c(0, size))
}

gg_cartesian <- function(size = 10, by = 2){
  
  df_cart <- df_cart_axis(size, by)
  
  p <- gg_null() +
    geom_segment(data = df_cart,
                 aes(x = x, y = y, xend = xend, yend = yend),
                 arrow = arrow(length = unit(0.25, "cm"), ends = "both"),
                 color = "gray10") 
  p
  
}


df_points <- data.frame(x = c(1, 2, 5), y = c(-2, -3, 5), label = letters[1:3])

gg_cartesian() +
  geom_point(data = df_points, aes(x, y)) + 
  geom_text(data = df_points, aes(x, y, label = label),
            size = 5, hjust = 1, vjust = 1)



