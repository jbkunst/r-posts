#' ---
#' title: "Visualizing Sort Algorithms with ggplot"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#'    toc: yes
#' categories: R
#' layout: post
#' featured_image: /images/just-another-way-to-make-a-r-flavored-blog/github_fork_game.png
#' ---
#+ setup, echo=FALSE, warning=FALSE, message=FALSE
rm(list = ls())
library("dplyr")
library("tidyr")
library("ggplot2")
library("ggthemes")
library("viridis")
theme_set(theme_map())
knitr::opts_chunk$set(dpi = 108)

#' Have you read [Visualizing Algorithms](http://bost.ocks.org/mike/algorithms/) by Mike Bostock? It's a *pure gold post*.
#' In that post Mike show a *static* representation of a sort algorith and obvious it will fun to replicate that image
#' with ggplot. So here we go.

#' We need some sorts algorihms. In # http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm you can
#' see some algorithms. 
#'  
#' We start with Insertion Sort:
insertion_sort_steps <- function(x  = sample(1:15)){
  
  msteps <- matrix(data = x, ncol = length(x))
  
  for (i in 2:length(x)) {
    
    j <- i
    
    while ((j > 1) && (x[j] < x[j - 1])) {
      
      temp <- x[j]
      x[j] <- x[j - 1]
      x[j - 1] <- temp
      j <- j - 1
      
      msteps <- rbind(msteps, as.vector(x))
      
    }
  }
  
  msteps
  
}

#' Now to test it and see what the function do:

set.seed(12345)

x <- sample(seq(4))

x

msteps <- insertion_sort_steps(x)

msteps

#' Every *row* is a step in sort the algorithm (a partial sort). This matrix is a hard to plot so 
#' we need a nicer structure. We can transform the matrix to a *data_frame* 
#' with the information of every *position* of every *element* in each *step*. 

sort_matix_to_df <- function(msteps){
  
  df <- as.data.frame(msteps, row.names = NULL)
  
  names(df) <- seq(ncol(msteps))
  
  df_steps <- df %>%
    tbl_df() %>% 
    mutate(step = seq(nrow(.))) %>% 
    gather(position, element, -step) %>%
    arrange(step)
  
  df_steps
  
}

#' And we apply this function to the previous *steps matrix*.
df_steps <- sort_matix_to_df(msteps)

head(df_steps, 10)

#' The next step will be plot the data frame.
plot_sort <- function(df_steps, size = 5, color.low = "#D1F0E1", color.high = "#524BB4"){
  
  ggplot(df_steps,
         aes(step, position, group = element, color = element, label = element)) +  
    geom_path(size = size, alpha = 1, lineend = "round") +
    scale_colour_gradient(low = color.low, high = color.high) +
    coord_flip() + 
    scale_x_reverse() + 
    theme(legend.position = "none")
  
}

#' Now compare this:
msteps

#' With:
#+ fig.width=3.5
plot_sort(df_steps, size = 6) + geom_text(color = "white", size = 4)

#' It works, so we can now scroll! 
#+ fig.width = 8, fig.height=35
sample(seq(70)) %>% 
  insertion_sort_steps() %>% 
  sort_matix_to_df() %>% 
  plot_sort(size = 2.2)


#+ echo=FALSE
library("printr")

#' Now try with other sort algorithms:
#' 
#' Bubble sort:
bubble_sort_steps <- function(x = sample(1:15)){
  
  msteps <- matrix(data = x, ncol = length(x))
  
  for (i in 1:(length(x) - 1)) {
    
    for (j in 1:(length(x) - 1)) {
      
      if (x[j] > x[j + 1]) {
        temp <- x[j]
        x[j] <- x[j + 1]
        x[j + 1] <- temp
      }
      
      msteps <- rbind(msteps, as.vector(x))
      
    }
  }
  
  msteps
  
}

#' Selection sort:
selection_sort_steps <- function(x = sample(1:15)){
  
  msteps <- matrix(data = x, ncol = length(x))
  
  for (i in 1:(length(x) - 1)) {
    
    smallsub <- i
    
    for (j in (i + 1):(length(x) - 0)) { # Is not - 1 like website
      
      if (x[j] < x[smallsub]) {
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

#' And test with a longer vector:

n <- 50
x <- sample(seq(n))

big_df <- rbind(
  x %>% selection_sort_steps() %>% sort_matix_to_df() %>% mutate(sort = "Selection Sort"),  
  x %>% insertion_sort_steps() %>% sort_matix_to_df() %>% mutate(sort = "Insertion Sort"),
  x %>% bubble_sort_steps() %>% sort_matix_to_df() %>% mutate(sort = "Bubble Sort")
)

head(big_df)

big_df %>%
  group_by(sort) %>% 
  summarise(steps = n())

#+ fig.width=8, fig.height=7
ggplot(big_df,
       aes(step, position, group = element, color = element, label = element)) +  
  geom_path(size = 0.8, alpha = 1, lineend = "round") +
  scale_colour_gradient(low = "#c21500", high = "#ffc500") + # http://uigradients.com/#Kyoto
  facet_wrap(~sort, scales = "free_x", ncol = 1) +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "transparent", linetype = 0),
        strip.text = element_text(size = 8))

#' Or we can plot vertical using the [viridis package](https://github.com/sjmgarnier/viridis): 
#+ fig.width=8, fig.height=20
ggplot(big_df,
       aes(position, step, group = element, color = element, label = element)) +  
  geom_path(size = 1, alpha = 1, lineend = "round") +
  scale_colour_gradientn(colours = viridis_pal()(n)) +
  facet_wrap(~sort, scales = "free_y", nrow = 1) +
  scale_y_reverse() +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "transparent", linetype = 0),
        strip.text = element_text(size = 8))

#' And that's it. If you write/implement another sort algorithm in this way let me know to view it ;). 

#' Some bonus content :D.
#' 
#' <iframe width="420" height="315" src="https://www.youtube.com/embed/M8xtOinmByo" frameborder="0" style="display: block;margin-left: auto;margin-right: auto;"></iframe>

#' References:
#' 
#' 1. http://bost.ocks.org/mike/algorithms/
#' 1. http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm
#' 1. http://corte.si/posts/code/visualisingsorting/
#' 1. http://uigradients.com/#Kyoto
#' 1. http://algs4.cs.princeton.edu/21elementary/

#+ featured_image, echo=FALSE, fig.width=8, fig.height=5, fig.show='hide'  
df <- data_frame(x = seq(1:20))
ggplot(df) + 
  geom_bar(aes(x = x, y = x, fill = x),
           stat = "identity",width = 0.5) +
  scale_colour_gradient(low = "white", high = "black") + 
  theme(legend.position = "none",
        plot.background = element_rect(fill = "black", colour = "black"),
        strip.text = element_text(size = 7))