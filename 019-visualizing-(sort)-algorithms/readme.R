#' ---
#' title: "Visualizing (Sort) Algorithms"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---
#+ echo=FALSE, warning=FALSE, message=FALSE
rm(list= ls())
library("dplyr")
library("tidyr")
library("ggplot2")
library("ggthemes")
library("printr")
library("stringr")

#' Have you read [Visualizing Algorithms](http://bost.ocks.org/mike/algorithms/) by Mike Bostock? It's a *magic post*. 

#' We need a sort algorihms. In # http://faculty.cs.niu.edu/~hutchins/csci230/sorting.htm you can see some algorithm. 
#' 
insertion_sort_steps <- function(x  = sample(1:15)){
  
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

#' Let's see what it does:

set.seed(12345)

x <- sample(seq(4))

x

msteps <- insertion_sort_steps(x)

msteps

#' Every *row* is a step with the partial sort in the algorithm.

#' Now for plotting we need a nicer structure. So we can have a *data_frame* with the information of every *position* of every *element* in each *step*. 
#' 
#' The plot function:

sort_matix_to_df <- function(msteps){
  
  df <- as.data.frame(msteps, row.names = NULL)
  
  names(df) <- seq(ncol(msteps))
  
  df_steps <- df %>%
    tbl_df() %>% 
    mutate(step = seq(nrow(.))) %>% 
    gather(position, element, -step) %>%
    # mutate(position = position %>% as.character() %>% as.numeric())
    arrange(step)
  
  df_steps
  
}


#' And we apply this function to the previous *step matrix*.

df_steps <- sort_matix_to_df(msteps)

cbind(df_steps %>% head(nrow(.)/2), df_steps %>% tail(nrow(.)/2))

#' The next step will be plot data frame.


plot_sort <- function(df_steps, size = 5, color.low = "#D1F0E1", color.high = "#524BB4"){
  
  ggplot(df_steps, aes(step, position, group = element, color = element, label = element)) +  
    geom_path(size = size, alpha = 1, lineend = "round") +
    # geom_text(color = "gray") +
    scale_colour_gradient(low = color.low , high= color.high) +
    coord_flip() + 
    scale_x_reverse() + 
    ggthemes::theme_map() + theme(legend.position = "none")
  
}

#+ fig.width=3.5
plot_sort(df_steps)

# 

#+ fig.width = 4, fig.height=20
sample(1:25) %>% 
  insertion_sort_steps() %>% 
  sort_matix_to_df() %>% 
  plot_sort(size = 4)




#' To order

#' Bubble sort
bubble_sort_steps <- function(x = sample(1:15)){
  
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

# selectopm
selection_sort_steps <- function(x = sample(1:15)){
  
  msteps <- matrix(data = x, ncol = length(x))
  
  for(i in 1:(length(x) - 1)){ # i <- 1
    
    smallsub <- i
    
    for(j in (i + 1):(length(x) - 1)){
      
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



#' Insertion Sort
insertion_sort_steps <- function(x  = sample(1:15)){
  
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



x <- sample(1:10)


#+ fig.width = 2.8
x %>% selection_sort_steps() %>% sort_matix_to_df() %>%  plot_sort()
x %>% insertion_sort_steps() %>% sort_matix_to_df() %>%  plot_sort()
x %>% bubble_sort_steps() %>% sort_matix_to_df() %>%  plot_sort()


big_df <- rbind(
  x %>% selection_sort_steps() %>% sort_matix_to_df() %>% mutate(sort = "selection"),  
  x %>% insertion_sort_steps() %>% sort_matix_to_df() %>% mutate(sort = "insertion"),
  x %>% bubble_sort_steps() %>% sort_matix_to_df() %>% mutate(sort = "bubble")
)

head(big_df)
str(big_df)

big_df %>%
  group_by(sort) %>% 
  summarise(steps = n())


#+ fig.width =5, fig.height=20
ggplot(big_df, aes(step, position, group = element, color = element, label = element)) +  
  geom_path(size = 4, alpha = 1, lineend = "round") +
  # geom_text(color = "gray") +
  scale_colour_gradient(low = "gray" , high= "black") +
  facet_grid(. ~ sort) + 
  coord_flip() + 
  scale_x_reverse() + 
  ggthemes::theme_map() + theme(legend.position = "none") +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "transparent",
                                        linetype = 0),
        strip.text = element_text(size = 12))

 

#' <iframe width="420" height="315" src="https://www.youtube.com/embed/M8xtOinmByo" frameborder="0"></iframe>