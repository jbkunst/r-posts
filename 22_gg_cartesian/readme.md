    library("ggplot2")
    library("ggthemes")

    ## Warning: package 'ggthemes' was built under R version 3.2.1

    library("stringr")

    ## Warning: package 'stringr' was built under R version 3.2.1

    library("dplyr")

    ## 
    ## Attaching package: 'dplyr'
    ## 
    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    library("grid")

    rm(list = ls())
    size = 10; by = 2


    gg_null <- function(){
     
      ggplot() +
        theme_map() +
        coord_equal()
      
    }

    df_cart_axis <- function(size = 10){
      
      data_frame(x = c(-size, 0),
                 y = c(0, -size),
                 xend = c(size, 0),
                 yend = c(0, size))
      
    }

    df_cart_labels <- function(size = 10, by = 2, size.ticks = 0.1){
      
      axis <- seq(0, size, by = by)
      axis <- setdiff(axis, 0)
      axis <- c(-rev(axis), axis)
      
      axis0 <- rep(0, length(axis))
      
      df_labels <- data_frame(x = c(axis, axis0),
                              y = c(axis0, axis),
                              label = ifelse(x != 0, x, y))
      
    #   df_labels <- df_labels %>%
    #     mutate(label = str_pad(label, side = "left", width = max(nchar(label))))
    #   
      df_labels 
      
    }

    gg_cartesian <- function(size = 10, by = 2){
      
      df_cart <- df_cart_axis(size)
      df_lbls <- df_cart_labels(size, by)
      
      graphics.off()

      gg_null() +
        geom_segment(data = df_cart,
                     aes(x, y, xend = xend, yend = yend),
                     arrow = arrow(length = unit(0.25, "cm"), ends = "both"),
                     color = "gray10") + 
        geom_text(data = df_lbls %>% filter(x == 0), aes(x + 1, y, label = label)) + 
        geom_text(data = df_lbls %>% filter(y == 0), aes(x, y - 1, label = label))  
      
      
    }

    gg_cartesian()
