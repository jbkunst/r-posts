#' ---
#' title: "Visualizing (Sort) Algorithms"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---
# http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm
#+ warning=FALSE, message=FALSE
library("dplyr")
library("tidyr")
library("ggplot2")
library("ggthemes")
library("viridis")

#'  Selection sort
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

#' Bubble sort
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

#' Insertion Sort
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

#' A function to get a plotteable data frame
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

#' A simple function to plot
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

#' Let see what it looks
x <- sample(1:25)

x %>% matrix_selection_sort() %>% sort_matix_to_df() %>%  plot_sort()
x %>% matrix_insertion_sort() %>% sort_matix_to_df() %>%  plot_sort()
x %>% matrix_bubble_sort() %>% sort_matix_to_df() %>%  plot_sort()


big_df <- rbind(
  x %>% matrix_selection_sort() %>% sort_matix_to_df() %>% mutate(sort = "selection"),  
  x %>% matrix_insertion_sort() %>% sort_matix_to_df() %>% mutate(sort = "insertion"),
  x %>% matrix_bubble_sort() %>% sort_matix_to_df() %>% mutate(sort = "bubble")
)

head(big_df)

big_df %>%
  group_by(sort) %>% 
  summarise(steps = n())

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

