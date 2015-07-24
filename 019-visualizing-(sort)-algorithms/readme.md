# Visualizing (Sort) Algorithms
Joshua Kunst  


```r
# http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm
```

```r
library("dplyr")
library("tidyr")
library("ggplot2")
library("ggthemes")
library("viridis")
```

 Selection sort


```r
matrix_selection_sort <- function(x = sample(1:15)){
  
  msteps <- matrix(data = x, ncol = length(x))
  
  for(i in 1:(length(x) - 1)){
    
    smallsub <- i
    
    for(j in (i + 1):(length(x) - 1)){
      
      if (x[j] > x[smallsub]) {
        smallsub <- j
      }
    }
    
    temp <- x[i]
    x[i] <- x[smallsub]
    x[smallsub] <- temp
    
    msteps <- rbind(msteps, as.vector(x))
    
  }
  
  msteps
  
}
```

Bubble sort


```r
matrix_bubble_sort <- function(x = sample(1:15)){
  
  msteps <- matrix(data = x, ncol = length(x))
  
  for(i in 1:(length(x) - 1)){
    
    for(j in 1:(length(x) - 1)){
      
      if(x[j] > x[j+1]){
       
        temp <- x[j]
        x[j] <- x[j + 1]
        x[j + 1] <- temp
        
        msteps <- rbind(msteps, as.vector(x))
      
      }
    }
  }
  
  msteps
  
}
```

Insertion Sort


```r
matrix_insertion_sort <- function(x  = sample(1:15)){

  msteps <- matrix(data = x, ncol = length(x))
  
  for(i in 2:length(x)){
    
    j <- i
    
    while( (j > 1) && (x[j] < x[j-1])) {
      
      temp <- x[j]
      x[j] <- x[j-1]
      x[j-1] <- temp
      j <- j - 1
      
      msteps <- rbind(msteps, as.vector(x))
      
    }
  }
  
  msteps
  
}
```

A function to get a plotteable data frame


```r
sort_matix_to_df <- function(msteps){
  
  df <- as.data.frame(msteps, row.names = NULL)
  
  els <- paste0("el_", seq(ncol(df)))
  stps <- paste0("step_", seq(nrow(df)))
  
  names(df) <- els
  
  df_steps <- df %>% 
    mutate(step = stps) %>% 
    gather(el, position, -step) %>% 
    mutate(step = factor(step, levels = rev(stps)),
           el = factor(el, levels = els))
  
  df_steps
  
}
```

A simple function to plot


```r
plot_sort <- function(df_steps){
  
  n_els <- levels(df_steps$el) %>% length()
  
  p <- ggplot(df_steps) +  
    geom_line(aes(step, position, group = el, color = el),
              size = 2, alpha = 1) +
    scale_color_manual(values = viridis(n_els)) +
    coord_flip() + 
    ggthemes::theme_map() + theme(legend.position = "none")
  
  p
  
}
```

Let see what it looks


```r
x <- sample(1:25)

x %>% matrix_selection_sort() %>% sort_matix_to_df() %>%  plot_sort()
```

![](readme_files/figure-html/unnamed-chunk-8-1.png) 

```r
x %>% matrix_insertion_sort() %>% sort_matix_to_df() %>%  plot_sort()
```

![](readme_files/figure-html/unnamed-chunk-8-2.png) 

```r
x %>% matrix_bubble_sort() %>% sort_matix_to_df() %>%  plot_sort()
```

![](readme_files/figure-html/unnamed-chunk-8-3.png) 

```r
big_df <- rbind(
  x %>% matrix_selection_sort() %>% sort_matix_to_df() %>% mutate(sort = "selection"),  
  x %>% matrix_insertion_sort() %>% sort_matix_to_df() %>% mutate(sort = "insertion"),
  x %>% matrix_bubble_sort() %>% sort_matix_to_df() %>% mutate(sort = "bubble")
)

head(big_df)
```

```
##     step   el position      sort
## 1 step_1 el_1        3 selection
## 2 step_2 el_1       25 selection
## 3 step_3 el_1       25 selection
## 4 step_4 el_1       25 selection
## 5 step_5 el_1       25 selection
## 6 step_6 el_1       25 selection
```

```r
big_df %>%
  group_by(sort) %>% 
  summarise(steps = n())
```

```
## Source: local data frame [3 x 2]
## 
##        sort steps
## 1    bubble  3475
## 2 insertion  3475
## 3 selection   625
```

```r
n_els <- levels(big_df$el) %>% length()

ggplot(big_df) +
  geom_line(aes(step, position, group = el, color = el), size = 2, alpha = 1) +
  scale_color_manual(values = viridis(n_els)) +
  facet_grid(sort ~ .) + 
  theme_map() +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "transparent",
                                        linetype = 0),
        strip.text = element_text(size = 12))
```

![](readme_files/figure-html/unnamed-chunk-8-4.png) 


---
title: "readme.R"
author: "jkunst"
date: "Fri Jul 24 15:51:08 2015"
---
